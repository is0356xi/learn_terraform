# 呼び出し時に渡される引数を定義
variable env {}


/*
    ""で初期化されている変数　　→　指定がなければ(""のままであれば)環境固有の変数を読み込む
    nullで初期化されている変数　→　依存リソース作成後に格納されるので動的
*/

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


# ネットワークインタフェースのパラメータ
variable nic_params{
    default = {
        nic1 = {
            name = "nic1"
            rg_name = ""
            location = ""
            ip_conf = {
                name = "ipconfig1"
                pip_alloc = "Dynamic"
                subnet_id = null
            }
        },

        nic2 = {
            name = "nic2"
            rg_name = ""
            location = ""
            ip_conf = {
                name = "ipconfig2"
                pip_alloc = "Dynamic"
                subnet_id = null
            }
        }
    }
}
