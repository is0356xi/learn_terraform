# 既存のリソースグループ内のリソースを取得する
data azurerm_resources rg{
    resource_group_name = var.rg_name

    required_tags = {
        source = "${local.env_name}_terraform"
    }
}

data azurerm_resources type {
    type = var.type
    required_tags = {
        tostring(var.tag.key) = var.tag.value
    }
}

output resources{
    # value = data.azurerm_resources.rg.resources
    value = data.azurerm_resources.type.resources
}