# NICを作成
resource "azurerm_network_interface" "nic" {
  for_each = var.avd_sessionHost_params.nic

  name                = each.value.name
  resource_group_name = var.env_params.resource_group_name
  location            = var.env_params.location

  ip_configuration {
    name                          = "${each.value.name}_config"
    subnet_id                     = var.created_subnet[each.value.subnet_name].id
    private_ip_address_allocation = "Dynamic"
  }
}

# セッションホストVMの作成
resource "azurerm_windows_virtual_machine" "vm" {
  for_each = var.avd_sessionHost_params.vm

  name                = each.value.name
  resource_group_name = var.env_params.resource_group_name
  location            = var.env_params.location

  size                  = each.value.size
  network_interface_ids = [azurerm_network_interface.nic[each.value.nic_name].id]
  provision_vm_agent    = true
  admin_username        = var.avd_local_admin_params.user_name
  admin_password        = var.avd_local_admin_params.password

  os_disk {
    name                 = "${each.value.name}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
  }

  depends_on = [azurerm_network_interface.nic]
}

# VMのドメイン参加設定
resource "azurerm_virtual_machine_extension" "domain_join" {
  for_each = var.avd_sessionHost_params.domain_join

  name                       = each.value.name
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[each.value.vm_name].id
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = data.template_file.settings_domain_join.rendered

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${var.dc_admin_params.password}"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

data "template_file" "settings_domain_join" {
  template = file("../../../modules/AVD/sessionHosts/extensions/settings_domain_join.json")
  vars = {
    domain_name  = var.dc_admin_params.domain_name
    ou_path      = ""
    domain_admin = var.dc_admin_params.user_principal_name
  }
}


# VMのDSC設定
resource "azurerm_virtual_machine_extension" "dsc" {
  for_each = var.avd_sessionHost_params.dsc

  name                       = each.value.name
  virtual_machine_id         = azurerm_windows_virtual_machine.vm[each.value.vm_name].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${var.created_hostpool[each.value.host_pool_name].name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "properties": {
        "registrationInfoToken": "${var.registration_token[each.value.host_pool_name]}"
      }
    }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.domain_join
  ]
}