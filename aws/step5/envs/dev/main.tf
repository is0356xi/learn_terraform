/*
作成するリソースを指定するファイル
moduleを呼び出してリソースを作成する
*/

##### IAM #####
# IAMユーザを作成
module "iam_user" {
  source     = "../../modules/IAM/users"
  env_params = var.env_params

  user_params  = var.user_params
  keybase_user = var.keybase_user
}

# 暗号化されたログインパスワードをアウトプット
output "passwords" {
  value = zipmap(module.iam_user.created_iam_user, module.iam_user.encrypted_password)
}

# IAMグループを作成→ポリシーをアタッチ→グループにメンバーを追加する
module "iam_group" {
  source     = "../../modules/IAM/groups"
  env_params = var.env_params

  group_params = var.group_params
  user_params  = var.user_params
}


# デバッグ用にoutputを定義
# output debug{
#     value = {
#         # <変数名> = <module側で定義されているoutput名>
#         created_resource = module.xxx.OutputName
#     }
# }




