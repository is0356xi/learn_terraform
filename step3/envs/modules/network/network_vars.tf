# 呼び出し時に渡される引数を定義
variable env {}
variable dev_conf {}

# 仮想ネットワークのパラメータ
variable vn_params{
    default = {
        name = "vnet",
        addr_space = ["10.0.0.0/22"]
        rg_name = ""
    }
}


# サブネットのパラメータ
variable sn_params{
    default = {
        subnet1 : {
            name = "subnet1"
            rg_name = ""
            addr_prefix = ["10.0.0.0/24"]
            vn_name = null # 仮想ネットワーク作成後に値が決まるためnullに設定
        },
        subnet2 : {
            name = "subnet2"
            rg_name = ""
            addr_prefix = ["10.0.1.0/24"]
            vn_name = null # 仮想ネットワーク作成後に値が決まるためnullに設定
        }
    }
}
