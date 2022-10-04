locals {
    # 環境名は何度も使うので、local変数に格納しておく
    env = var.env.name
}


resource azurerm_virtual_network vn{
    name = "${local.env}_${var.vn_params.name}"  # dev_vnet となる
    address_space = var.vn_params.addr_space
    location = var.dev_conf.location
    # パラメータファイルでリソースグループが設定されていない場合は、dev既定のリソースグループに作成する 
    resource_group_name = (var.vn_params.rg_name == "")? var.dev_conf.rg_name : var.vn_params.rg_name

    # モジュール呼び出し時に受け取った環境情報を使用してタグを設定する
    tags = {
        source = "${local.env}_terraform"
    }
}