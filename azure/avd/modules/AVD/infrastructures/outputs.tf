output "host_pool_registration" {
  value = azurerm_virtual_desktop_host_pool_registration_info.registration
}

output "created_hostpool" {
  value = azurerm_virtual_desktop_host_pool.host_pool
}

output "created_dag" {
  value = azurerm_virtual_desktop_application_group.dag
}