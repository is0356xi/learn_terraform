# Azure Resource Managerをプロバイダーに指定
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

# リソースグループ：test_rgを作成する
resource "azurerm_resource_group" "rg" {
  name     = "test_rg"
  location = "japaneast"
}