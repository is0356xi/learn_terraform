/*
    一つのネットワークセキュリティグループに複数のルールが存在する → variableが多重階層となる
    countとfor_eachを使って多重階層を処理する。

    count　→　各ネットワークセキュリティグループのループ
    for_each & dynamic content →　各NSGの中の、ルールのループ
*/

# NSGの作成
resource azurerm_network_security_group nsg{
    # NSGのループ処理
    count = length(var.nsg_conf)

    name = element(keys(var.nsg_conf), count.index)
    location = (local.nsg_conf[count.index].location == "") ? var.env.config.location : local.nsg_conf[count.index].location
    resource_group_name = (local.nsg_conf[count.index].rg_name == "") ? var.env.config.rg_name : local.nsg_conf[count.index].rg_name

    # 各NSGの中の、ルールのループ処理
    dynamic security_rule {  
        for_each = local.nsg_conf[count.index].rules

        content {
            name                         = security_rule.key
            priority                     = security_rule.value.priority
            direction                    = security_rule.value.direction
            access                       = security_rule.value.access
            protocol                     = security_rule.value.protocol
            source_port_range            = security_rule.value.src_port
            source_address_prefixes      = security_rule.value.src_addrs
            destination_port_range       = security_rule.value.dst_port
            destination_address_prefixes = security_rule.value.dst_addrs
        }   
    }

    tags = {
        source = "${local.env_name}_terraform"
    }
}


# NSGをNICにアタッチ (NICのIDを取得した後、各NICにNSGを割り当てる)
module get_nic{
    source = "../../get_existing_resource"

    env     = var.env
    rg_name = var.exist.rg_name
    type    = var.exist.type
    tag     = {
        key   = var.exist.tag.key
        value = var.exist.tag.value
    }
}


resource azurerm_network_interface_security_group_association nic_nsg{
    count = length(azurerm_network_security_group.nsg)

    network_interface_id      = module.get_nic.resources[count.index].id
    network_security_group_id = azurerm_network_security_group.nsg[count.index].id
}