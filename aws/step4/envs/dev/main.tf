/*
module呼び出しテンプレート

module <module名>{
  source = "../../modules/<moduleのpath>"
  env_params = var.env_params

  # 以下、モジュールに渡す変数群
}
*/


######  network作成  ######

# module "vpc" {
#   source     = "../../modules/Vpc/vpc"
#   env_params = var.env_params

#   vpc_params = var.vpc_params
# }

# module subnet{
#   source = "../../modules/Vpc/subnet"
#   env_params = var.env_params

#   subnet_params = var.subnet_params
#   created_vpc = module.vpc.created_vpc

# }


######  IAM関連リソースの作成  ######

module iam_user{
  source = "../../modules/Iam/users"
  env_params = var.env_params

  user_params = var.user_params
}

module iam_group{
  source = "../../modules/Iam/groups"
  env_params = var.env_params

  group_params = var.group_params
  user_params = var.user_params

  depends_on = [module.iam_user]
}

# ログインパスワードを出力
output passwords {
  # zipmap([a,b], [c,d]) --> {a=b, c=d}
  value = zipmap(module.iam_user.created_iam_user, module.iam_user.encrypted_password)
  # value = zipmap(module.iam_user.created_iam_user, module.iam_user.encrypted_secret)
}

# アクセスキーを出力
output access_keys {
  value = zipmap(module.iam_user.created_iam_user, module.iam_user.encrypted_secret)
}

output "debug" {
  value = {
    # created_vpc = module.vpc.created_vpc,
    # created_subnet = module.subnet.created_subnet
    # created_iam_group = module.iam_group.created_iam_group
    # created_iam_user = module.iam_user.created_iam_user

  }
}