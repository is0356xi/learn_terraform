module "aadds" {
  # moduleの場所を指定
  source = "../../../modules/ADDS"

  # 環境固有の変数を渡す
  env_params = var.env_params

  # AADDS構築のパラメータをモジュールに渡す
  aadds_params = var.aadds_params

  # AADDS管理者のパラメータを渡す
  dc_admin_params = var.dc_admin_params
}


output "aadds_vnet" {
  value = module.aadds.created_vnet
}

output "aadds_subnet" {
  value = module.aadds.created_subnet
}