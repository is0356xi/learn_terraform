# ストレージアカウントを作成
resource "azurerm_storage_account" "storage" {
  name                = var.storage_params.avd_storage.name
  resource_group_name = var.env_params.resource_group_name
  location            = var.env_params.location

  account_tier             = var.storage_params.avd_storage.account_tier
  account_kind             = var.storage_params.avd_storage.account_kind
  account_replication_type = var.storage_params.avd_storage.account_replication_type

  azure_files_authentication {
    directory_type = var.storage_params.avd_storage.azure_files_authentication.directory_type
  }
}

# Azure File共有を作成
resource "azurerm_storage_share" "share" {
  name                 = var.storage_params.fslogix.name
  quota                = var.storage_params.fslogix.quota
  storage_account_name = azurerm_storage_account.storage.name
  depends_on           = [azurerm_storage_account.storage]
}

# AVDユーザグループにファイル共有を許可するロールを取得
data "azurerm_role_definition" "role" {
  name = "Storage File Data SMB Share Contributor"
}

# ロールをアタッチ
resource "azurerm_role_assignment" "role" {
  for_each = var.avd_group

  scope              = azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = each.value.id
}