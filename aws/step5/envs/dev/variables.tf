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
  }
}


##### IAM #####
# IAMユーザのパラメータ
variable "user_params" {
  # default = {
  #   admin1 = {
  #     name  = "admin1"
  #     group = "administrators"
  #   },
  #   admiin2 = {
  #     name  = "admiin2"
  #     group = "administrators"
  #   },
  #   developer1 = {
  #     name  = "developer1"
  #     group = "developers"
  #   }
  # }
}

# IAMグループのパラメータ
variable "group_params" {
  default = {
    administrators = {
      name   = "administrators"
      path   = "/"
      policy = "administrator"
    },
    developers = {
      name   = "developers"
      path   = "/"
      policy = "developer"
    }
  }
}