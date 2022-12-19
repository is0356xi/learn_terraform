/*
リソース作成時のパラメータを定義するファイル。
リソースの構成・設定は全てこのファイルに記述される。
*/

# terraform.tfvarsの変数を読み込む際は、変数名を一致させた空のvariable{}をこのファイルに定義
variable "aws_access_key" {}
variable "aws_secret_key" {}


# 変数の定義例
variable str {
  default     = ""
}

variable list {
    default = []
}

variable dict{
    default = {}
}