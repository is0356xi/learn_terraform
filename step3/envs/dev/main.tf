# provider情報を読み込み
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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

provider "azurerm" {
  features {}
}


# 基本的なネットワークリソースの作成
module "network" {
  # networkモジュールの呼び出し
  source = "../../modules/network"
  # 環境に関する情報をモジュールへ渡す
  env = var.env
}


# 仮想マシンの作成
module "vm" {
  source = "../../modules/vm"

  env = var.env            # 環境に関する情報をモジュールへ渡す
  nic = module.network.nic # networkモジュールでoutputされた"nic"をvmモジュールへ渡す
}


# ネットワークセキュリティグループの作成
module nsg{
  source = "../../modules/network/nsg"
  env = var.env
}


# # ユーザ定義ルートの作成
module udr{
  source = "../../modules/network/udr"
  env = var.env
}




#####  デバッグ用  ############

# 既存リソースの取得モジュール（デバッグ用）
# module get_existing_resources{
#   source = "../../modules/get_existing_resource"

#   # 環境情報を読み込み
#   env = var.env

#   # 既存のリソースグループ内のリソースを取得したい場合
#   rg_name = (var.exist.rg_name == "") ? "tf_${var.env.name}" : var.exist.rg_name 
#   # rg_name = "none"

#   # 既存の仮想ネットワークを取得したい場合
#   type = var.exist.type.subnet

#   # タグでフィルターしたい場合
#   tag = {
#     key    = var.exist.tag.key 
#     value = var.exist.tag.value
#   }
# }

# output exist_resource{
#   value = module.get_existing_resources
# }