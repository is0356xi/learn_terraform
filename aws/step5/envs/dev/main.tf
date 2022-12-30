/*
作成するリソースを指定するファイル
moduleを呼び出してリソースを作成する
*/

##### IAM #####
# IAMユーザ・グループを作成
module "iam" {
  source     = "../../modules/IAM"
  env_params = var.env_params

  user_params  = jsondecode(file("users.json"))
  keybase_user = var.keybase_user
  group_params = var.group_params
}

# 暗号化されたログインパスワードをアウトプット
output "passwords" {
  value = zipmap(module.iam.created_iam_user, module.iam.encrypted_password)
}


# デバッグ用にoutputを定義
output "debug" {
  value = {
    # <変数名> = <module側で定義されているoutput名>
    custom_policy_user = module.iam.debug
  }
}




