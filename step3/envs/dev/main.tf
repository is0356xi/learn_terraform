# provider情報を読み込み
terraform {
    required_providers{
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~> 3.0.2"
        }
    }

    # tfstateの保存・管理を行う場所
    # backend "azurerm" {
    #     /*
    #         BLOBストレージの情報を<環境名>.tfbackendに記述
    #         init時にバックエンドファイルを指定することで環境を指定できる
    #         terraform init -reconfigure -backend-config ../../backend/<環境名>.tfbackend
    #     */
    # }
    

    required_version = ">= 1.1.0"
}

provider "azurerm"{
    features {}
}

# dev環境固有の変数を読み込み
module dev{
    source = "../../modules/config"
}


# ネットワークリソースの作成
module network{
    # networkモジュールの呼び出し
    source = "../../modules/network"

    env = var.env                  # 環境に関する情報をモジュールへ渡す
    dev_conf = module.dev.config   # dev_confという変数名で"../config"の値をnetworkモジュールに渡す
    
}

