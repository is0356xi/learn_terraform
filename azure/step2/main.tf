# terraform.tfvarsから読み込む変数を定義
variable target {}

# Azure Resource Managerをプロバイダーに指定
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}


# ローカル内で使用する変数
locals {
  # json形式で保存したtfstateを読み込み
  tfstate = jsondecode(file("terraform.tfstate.json"))

  # tfstateのresourcesリストを取得
  resources_list = local.tfstate.resources

  
  # target.target_nameに該当するresouceからinstancesを取り出し
  # リスト内包表記→　for <listの各値> in [list] : <取り出したい値> if (取り出し条件)
  instances = [for x in local.resources_list: x.instances if x.name==var.target.target_name] 
  # [[instancesのlist]]という形式になっているので0番目を取り出し
  instances_list = local.instances[0] 


  # target.instance_nameに該当するlocation, nameを取り出し
  location = [for y in local.instances_list: y.attributes.location if y.attributes.name==var.target.instance_name]
  name = [for z in local.instances_list: z.attributes.name if z.attributes.name==var.target.instance_name]
  new_name = "${local.name[0]}_2" # 既存のリソース名_2 に設定


  # map形式で新規リソースの情報を格納
  new_resouce = {
    resource1 = {
      name = local.new_name
      location = local.location[0]
    }
  }
}




# 既存リソースのimport用(import元と同一type/nameのリソースブロックが必要), import後にコメントアウトしてよい
# resource "azurerm_resource_group" "terraform-rg" {
# }

# 新規リソース作成用
resource "azurerm_resource_group" "terraform-rg_2" {
  for_each = local.new_resouce

  name = each.value.name
  location = each.value.location
}