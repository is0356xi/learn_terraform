# 環境情報を受け取る
variable env{}

/*
    ""で初期化されている変数　　→　指定がなければ(""のままであれば)環境固有の変数を読み込む
    nullで初期化されている変数　→　依存リソース作成後に格納されるので動的
*/



/* nsg_confのrulesの規則
    ・rule_name = {ルールのパラメータマップ} で構成する 
    ・ルールのパラメータマップ は、以下を入力
        priority     :  [int]  優先度（低い順でルールが適用される） 
        direction    :　[str]  インバウンド or アウトバウンド
        access,      :　[str]  許可 or 拒否
        protocol     :　[str]  プロトコル（Tcp, Rdp, Icmp, Udp, *, etc）
        src_port     :　[str]  送信元のポート範囲 (80, 443, 3389, 443, 0-65535, etc)
        src_addrs    :　[list]  送信元のIPアドレス（VirtualNetwork, AzureLoadBlancer, 0.0.0.0/0, etc)
        dst_port     :　[str]  宛先のポート範囲 (80, 443, 3389, 443, 0-65535, etc)
        dst_addrs    :　[list] 宛先のIPアドレス（VirtualNetwork, Internet, 0.0.0.0/0, etc）            
*/

# ネットワークセキュリティグループの情報
variable nsg_conf{
    default = {
        nsg1 = {
            location = ""
            rg_name = ""
            
            rules = {        
                Allow_Icmp = {
                    priority    = 1000
                    direction   = "Inbound"
                    access      = "Allow"
                    protocol    = "Icmp"
                    src_port    = "*"
                    src_addrs   = ["133.200.161.129/32"]
                    dst_port    = "*"
                    dst_addrs   = ["10.0.0.0/24"]
                }

                Deny_Tcp = {
                    priority   = 1001
                    direction  = "Inbound"
                    access     = "Deny"
                    protocol   = "Tcp"
                    src_port   = "*"
                    src_addrs  = ["0.0.0.0/0"]
                    dst_port   = "*"
                    dst_addrs  = ["0.0.0.0/0"]
                }
                
            }
        },

        nsg2 = {
            location = ""
            rg_name = ""
            
            rules = {        
                Allow_Icmp = {
                    priority   = 1000
                    direction  = "Inbound"
                    access     = "Allow"
                    protocol   = "Icmp"
                    src_port   = "*"
                    src_addrs  = ["133.200.161.129/32"]
                    dst_port   = "*"
                    dst_addrs  = ["10.0.0.0/24"]
                }

                Deny_Tcp = {
                    priority   = 1001
                    direction  = "Inbound"
                    access     = "Deny"
                    protocol   = "Tcp"
                    src_port   = "*"
                    src_addrs  = ["0.0.0.0/0"]
                    dst_port   = "*"
                    dst_addrs  = ["0.0.0.0/0"]
                }
                
            }
        }

    }
}


# NSGをアタッチするNICを取得するための変数
variable exist{
    default = {
        rg_name = "none"

        type = "Microsoft.Network/networkInterfaces"

        tag = {
            key    = "source"
            value  = "dev_terraform"
        }
    }
}