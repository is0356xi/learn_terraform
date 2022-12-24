# Vnetを作成
resource "azurerm_virtual_network" "vnet" {
  for_each = var.vnet_params

  resource_group_name = var.env_params.resource_group_name.avd
  location            = var.env_params.location

  name          = each.value.name
  address_space = each.value.address_space
}
