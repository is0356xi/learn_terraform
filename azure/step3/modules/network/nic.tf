resource azurerm_network_interface nic{
    for_each = var.nic_params

    name = each.value.name
    resource_group_name = (each.value.rg_name == "") ? local.env_params.rg_name : each.value.rg_name
    location = local.env_params.location

    

    ip_configuration{
        name = each.value.ip_conf.name
        private_ip_address_allocation = each.value.ip_conf.pip_alloc
        subnet_id = azurerm_subnet.sn[
            element(
                keys(var.sn_params),
                index(keys(var.nic_params), each.key)
            )
        ].id
    }

    tags = {
        source = "${local.env_name}_terraform"
    }
}

output nic{
    value = {
        resources = azurerm_network_interface.nic
        nic_keys = keys(var.nic_params)
    }
}