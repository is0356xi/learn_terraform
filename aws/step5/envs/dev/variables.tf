# terraform.tfvarsの変数を読み込み
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "keybase_user" {}

# 環境固有の変数
variable "env_params" {
  default = {
    region = "ap-northeast-1"
    tag = {
      Name = "dev"
    }
    module_path = "../../modules"
  }
}


##### IAM #####
# IAMグループのパラメータ
variable "group_params" {
  default = {
    administrators = {
      name        = "administrators"
      path        = "/"
      policy_name = "AdministratorAccess"
    },
    developers = {
      name        = "developers"
      path        = "/"
      policy_name = "PowerUserAccess"
    }
  }
}