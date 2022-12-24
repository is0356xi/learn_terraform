# AADDS側のtfstateファイル内のoutputを取得する
data "terraform_remote_state" "aadds" {
  backend = "local"
  config = {
    path = "../AADDS/terraform.tfstate"
  }
}

# サブネットを作成
module "subnet" {
  source     = "../../../modules/Network/subnets"
  env_params = var.env_params

  # サブネットのパラメータ
  subnet_params = var.subnet_params

  # AADDSの仮想ネットワーク名
  aadds_vnet_name = data.terraform_remote_state.aadds.outputs.aadds_vnet.name
}


# AVD基盤を構築
module "avd_infrastructure" {
  source     = "../../../modules/AVD/infrastructures"
  env_params = var.env_params

  avd_infrastructure_params = var.avd_infrastructure_params
}

# ホストプールとトークンをマッピング
locals {
  token_map = zipmap(
    [for obj in module.avd_infrastructure.created_hostpool : obj.name],
    [for obj in module.avd_infrastructure.host_pool_registration : obj.token]
  )
}

# AVDのセッションホストを作成
module "avd_sessionhost" {
  source     = "../../../modules/AVD/sessionHosts"
  env_params = var.env_params

  # AVDセッションホストのパラメータ
  avd_sessionHost_params = var.avd_sessionHost_params

  # 作成済みのサブネット (VMをホストプールのサブネット上に構築するため)
  created_subnet = module.subnet.created_subnet

  # VMのローカル管理者に関するパラメータ
  avd_local_admin_params = var.avd_local_admin_params

  # AADDSの管理者に関するパラメータ
  dc_admin_params = var.dc_admin_params

  # ホストプール作成時に発行したトークン
  registration_token = local.token_map

  # 作成済みのホストプール (VMをホストプールのサブネット上に構築するため)
  created_hostpool = module.avd_infrastructure.created_hostpool

  depends_on = [module.avd_infrastructure]
}


# AVDユーザのパラメータを読み込み
locals {
  avd_user_params = jsondecode(file("avd_users.json"))
}

# AVDユーザ・グループを作成
module "avd_user" {
  source     = "../../../modules/AVD/users"
  env_params = var.env_params

  avd_user_params  = local.avd_user_params
  avd_group_params = var.avd_group_params
  created_dag      = module.avd_infrastructure.created_dag
}

# AzureFilesを作成
module "fslogix" {
  source     = "../../../modules/AVD/fslogix"
  env_params = var.env_params

  storage_params = var.storage_params
  avd_group      = module.avd_user.created_group
}

# デバッグ用にoutputを定義
output "debug" {
  value = {
    # <変数名> = <module側で定義されているoutput名>
    # registration_token = local.token_map
  }
}




