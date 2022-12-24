resource "azurerm_subnet" "subnet" {
  for_each = var.subnet_params

  resource_group_name = var.env_params.resource_group_name

  name                 = each.value.name
  address_prefixes     = each.value.address_prefixes
  virtual_network_name = var.aadds_vnet_name

  service_endpoints                              = ["Microsoft.Storage"]
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = false
}
