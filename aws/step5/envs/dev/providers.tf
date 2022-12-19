terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  # 各リソースにてタグ指定がない場合に付与するタグを設定
  default_tags {
    tags = var.env_params.tag
  }

  # tfvarsの情報を読み込む
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.env_params.region
}