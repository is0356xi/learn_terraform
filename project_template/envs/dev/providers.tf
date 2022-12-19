/*
プロバイダーの情報を記述するファイル
*/

##### AWS #####
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  # タグ指定されなかった場合、default_tagsが付与される
  default_tags {
    tags = var.env_params.tags
  }

  # tfvarsからシークレット情報を読み込み
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}



##### Azure #####
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

