# dev環境固有 & 上位の設定を記述
variable env{
    default = {
        # 環境名
        name = "dev"
        # dev環境の既定値
        config = {
            rg_name = "tf_dev"
            location = "japaneast"
        }
    }
}