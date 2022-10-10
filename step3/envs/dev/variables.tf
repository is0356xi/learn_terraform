# dev環境固有 & 上位の設定を記述
variable env {
  default = {
    # 環境名
    name = "dev"
    # dev環境の既定値
    config = {
      rg_name  = "tf_dev"
      location = "japaneast"
    }
  }
}

/*
    動的に決定する(ユーザが動的に入力する)変数は""で初期化
    ""の場合は、環境固有の変数が代入される。
*/

# 取得したい既存リソースの情報
variable exist{
  default = {
    # 指定リソースグループ内のリソースを取得する際に使用
    rg_name = ""

    # 指定リソースタイプのリソースを取得する際に使用
    type = {
      vnet = "Microsoft.Network/virtualNetworks"
      nic = "Microsoft.Network/networkInterfaces"
    }

    # タグでフィルターする際に使用
    tag = {
      key   = "source"
      value = "dev_terraform"
    }
  }
}
