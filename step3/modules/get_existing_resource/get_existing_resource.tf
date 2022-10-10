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

data azurerm_resources type_notag {
    type = var.type
}

output resources{
    value = {
        rg_tag      = data.azurerm_resources.rg.resources
        type_tag    = data.azurerm_resources.type.resources
        type_notag  = data.azurerm_resources.type_notag.resources
    }
}