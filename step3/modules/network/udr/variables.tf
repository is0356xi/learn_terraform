# 環境情報を受け取る
variable env{}


/*
    ""で初期化されている変数　　→　指定がなければ(""のままであれば)環境固有の変数を読み込む
    nullで初期化されている変数　→　依存リソース作成後に格納されるので動的
*/

# User Defined Routeの情報
variable udr_conf{
    default = {
        udr1 = {
            location = ""
            rg_name = ""
            disable_bgp = true

            routes = [
                { name ="AVD_BLOB", dst="133.10.0.5/32", type="Internet"},
                { name ="AVD_RDGW", dst="133.10.0.9/32", type="Internet"}
            ]     
        },

        udr2 = {
            location = ""
            rg_name = ""
            disable_bgp = true

            routes = [
                { name ="AVD_BLOB", dst="133.11.0.5/32", type="Internet"},
                { name ="AVD_RDGW", dst="133.11.0.9/32", type="Internet"}
            ]     
        }

    }
}


# UDRをアタッチするサブネットを取得するための変数 (NG)
# variable exist{
#     default = {
#         rg_name = "none"

#         type = "Microsoft.Network/Subnet"

#         tag = {
#             key   = "source"
#             value = "dev_terraform"
#         }
#     }
# }


variable exist_sn{
    default = {
        sn1 = {
            name = "subnet1"
            vn_name = "vnet"
            rg_name = "rg"
        },

        sn2 = {
            name = "subnet2"
            vn_name = "vnet"
            rg_name = "rg"
        },

    }
}