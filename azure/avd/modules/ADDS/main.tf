# サービスプリンシパルを作成
resource "azuread_service_principal" "service_principal" {
  application_id = "2565bd9d-da50-47d4-8b85-4c97f669dc36"
  tags           = ["AADDS"]
}

# リソースグループを作成
resource "azurerm_resource_group" "rg" {
  name     = var.env_params.resource_group_name
  location = var.env_params.location
}

# Vnetを作成
resource "azurerm_virtual_network" "vnet" {
  name                = var.aadds_params.aadds_vnet.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.env_params.location

  address_space = var.aadds_params.aadds_vnet.address_space
  dns_servers   = var.aadds_params.aadds_vnet.dns_servers
}

# サブネットを作成
resource "azurerm_subnet" "subnet" {
  name                 = var.aadds_params.aadds_subnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = var.aadds_params.aadds_subnet.address_prefixes
}


# リソースプロバイダーを登録
resource "azurerm_resource_provider_registration" "service_provider" {
  name = "Microsoft.AAD"
}


# NSGを作成
resource "azurerm_network_security_group" "nsg" {
  name                = "aadds-nsg"
  location            = var.env_params.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowRD"
    access                     = "Allow"
    priority                   = 201
    direction                  = "Inbound"
    protocol                   = "Tcp"
    source_address_prefix      = "CorpNetSaw"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "3389"
  }

  security_rule {
    name                       = "AllowPSRemoting"
    access                     = "Allow"
    priority                   = 301
    direction                  = "Inbound"
    protocol                   = "Tcp"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "5986"
  }
}

# NSGをサブネットに関連付け
resource "azurerm_subnet_network_security_group_association" "nsg_attach" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ドメイン管理者グループ・ユーザを作成
resource "azuread_group" "dc_admin_group" {
  display_name     = "AAD DC Administrators"
  security_enabled = true
}

resource "azuread_user" "dc_admin" {
  user_principal_name = var.dc_admin_params.user_principal_name
  display_name        = "DC Admin"
  password            = var.dc_admin_params.password
}

resource "azuread_group_member" "member" {
  group_object_id  = azuread_group.dc_admin_group.object_id
  member_object_id = azuread_user.dc_admin.object_id
}


# AADDSを作成
resource "azurerm_active_directory_domain_service" "aadds" {
  name                = var.aadds_params.aadds.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.env_params.location

  domain_name           = var.aadds_params.aadds.domain_name
  sku                   = var.aadds_params.aadds.sku
  filtered_sync_enabled = var.aadds_params.aadds.filtered_sync_enabled

  initial_replica_set {
    subnet_id = azurerm_subnet.subnet.id
  }

  notifications {
    notify_dc_admins     = true
    notify_global_admins = true
  }

  security {
    sync_kerberos_passwords = true
    sync_ntlm_passwords     = true
    sync_on_prem_passwords  = true
  }

  depends_on = [
    azuread_service_principal.service_principal,
    azurerm_resource_provider_registration.service_provider,
    azurerm_subnet_network_security_group_association.nsg_attach
  ]
}