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

# ネットワークリソースの作成
module network{
    # networkモジュールの呼び出し
    source = "../../modules/network"
    # 環境に関する情報をモジュールへ渡す
    env = var.env                  
    
}

