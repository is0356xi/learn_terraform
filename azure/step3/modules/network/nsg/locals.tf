locals {
    # 環境名、環境ごとの設定値は何度も使うので、local変数に格納しておく
    env_name = var.env.name
    env_params = var.env.config

    # NSGに関する設定
    nsg_conf = values(var.nsg_conf)
}
