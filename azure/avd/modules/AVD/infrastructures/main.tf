# AVDワークスペースを作成
resource "azurerm_virtual_desktop_workspace" "workspace" {
  for_each = var.avd_infrastructure_params.workspaces

  name                = each.value.name
  resource_group_name = var.env_params.resource_group_name
  location            = var.env_params.location
}

# ホストプールを作成
resource "azurerm_virtual_desktop_host_pool" "host_pool" {
  for_each = var.avd_infrastructure_params.host_pools

  resource_group_name = var.env_params.resource_group_name
  location            = var.env_params.location

  name                     = each.value.name
  type                     = each.value.type
  maximum_sessions_allowed = each.value.maximum_sessions_allowed
  load_balancer_type       = each.value.load_balancer_type
}

# ホストプール用のトークンを発行
resource "azurerm_virtual_desktop_host_pool_registration_info" "registration" {
  for_each = azurerm_virtual_desktop_host_pool.host_pool

  hostpool_id     = each.value.id
  expiration_date = var.avd_infrastructure_params.rfc3339
}

# アプリケーショングループを作成
resource "azurerm_virtual_desktop_application_group" "dag" {
  for_each = var.avd_infrastructure_params.application_groups

  resource_group_name = var.env_params.resource_group_name
  location            = var.env_params.location

  name         = each.value.name
  type         = each.value.type
  host_pool_id = azurerm_virtual_desktop_host_pool.host_pool[each.value.host_pool_name].id

  depends_on = [
    azurerm_virtual_desktop_host_pool.host_pool,
    azurerm_virtual_desktop_workspace.workspace
  ]
}

# ワークスペースとアプリケーショングループを関連付け
resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  for_each = var.avd_infrastructure_params.application_groups

  application_group_id = azurerm_virtual_desktop_application_group.dag[each.value.name].id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace[each.value.ws_name].id
}