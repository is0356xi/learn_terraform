resource "azurerm_resource_group" "rg" {
  name     = var.env_params.resource_group_name
  location = var.env_params.location
}