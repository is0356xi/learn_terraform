resource azurerm_route_table udr{
    count = length(var.udr_conf)
    
    name = element(keys(var.udr_conf), count.index)
    location = (local.udr_conf[count.index].location == "") ? var.env.config.location : local.udr_conf[count.index].location
    resource_group_name = (local.udr_conf[count.index].rg_name == "") ? var.env.config.rg_name : local.udr_conf[count.index].rg_name
    disable_bgp_route_propagation = local.udr_conf[count.index].disable_bgp

    dynamic route{
        # variablesファイルのルートリストをループで処理する
        for_each = local.udr_conf[count.index].routes

        content{
            name = route.value.name
            address_prefix = route.value.dst
            next_hop_type = route.value.type
        }
    }

    tags = {
        source = "${local.env_name}_terraform"   
    }
}


### UDRをサブネットにアタッチする (作成済みのサブネット取得→サブネットにアタッチ)

# 作成済みのサブネットを取得する (NG: サブネットはvirtulaNetworksのサブ機能なのでtypeで指定できない)
# module get_subnet{
#     source = "../../get_existing_resource"

#     env     = var.env
#     rg_name = var.exist.rg_name
#     type    = var.exist.type
#     tag     = {
#         key   = var.exist.tag.key
#         value = var.exist.tag.value
#     }
# }

# azurerm_subnetを使用する
data azurerm_subnet sn{
    for_each = var.exist_sn

    name                  = "${local.env_name}_${each.value.name}"
    virtual_network_name  = "${local.env_name}_${each.value.vn_name}"
    resource_group_name   = "${local.env_name}_${each.value.rg_name}"   
}



# サブネットにアタッチする
resource azurerm_subnet_route_table_association subnet_udr{
    count = length(azurerm_route_table.udr)

    subnet_id      = values(data.azurerm_subnet.sn)[count.index].id
    route_table_id = azurerm_route_table.udr[count.index].id
}

