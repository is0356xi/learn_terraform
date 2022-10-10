resource azurerm_windows_virtual_machine winvm{
    for_each = var.vm_params

    name = "${local.env_name}_${each.value.name}"
    computer_name = each.value.computer_name
    resource_group_name = (each.value.rg_name == "") ? local.env_params.rg_name : each.value.rg_name
    location = local.env_params.location
    admin_username = each.value.admin_name
    admin_password = each.value.admin_password
    size = each.value.size

    network_interface_ids = [
        var.nic.resources[
            element(
                var.nic.nic_keys,
                index(keys(var.vm_params), each.key)
            )
        ].id
    ]

    os_disk{
        storage_account_type = each.value.os_disk.type
        caching = each.value.os_disk.cach
    }

    source_image_reference {
        publisher = each.value.image.publisher
        offer     = each.value.image.offer
        sku       = each.value.image.sku
        version   = each.value.image.version
    }

    tags = {
        source = "${local.env_name}_terraform"
    }
}