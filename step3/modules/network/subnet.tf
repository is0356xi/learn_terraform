resource azurerm_subnet sn{
    # sn_paramsの各オブジェクトを取り出してループ処理
    for_each = var.sn_params

    name = "${local.env_name}_${each.value.name}"
    resource_group_name = (each.value.rg_name == "") ? local.env_params.rg_name : each.value.rg_name
    address_prefixes = each.value.addr_prefix
    # 同じ階層にあるのでoutput無しでazurerm_virtual_networkを参照可能
    virtual_network_name = azurerm_virtual_network.vn.name
}