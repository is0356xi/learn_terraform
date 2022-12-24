# terraform.tfvarsの変数を読み込み
variable "dc_admin_params" {}


# 環境固有のパラメータ
variable "env_params" {
  default = {
    name                = "dev"
    location            = "eastus"
    resource_group_name = "aadds-rg"
    tag = {
      Name = "from_tf"
    }
  }
}

# AADDS構築のパラメータ
variable "aadds_params" {
  default = {
    # Vnetのパラメータ
    aadds_vnet = {
      name          = "aadds-vnet"
      address_space = ["10.0.0.0/16"]
      dns_servers   = ["10.0.0.4", "10.0.0.5"] # AADDSに向ける
    }

    # サブネットのパラメータ
    aadds_subnet = {
      name             = "aadds-subnet"
      address_prefixes = ["10.0.0.0/24"]
    }

    # AADDSのパラメータ
    aadds = {
      name                  = "aadds"
      domain_name           = "avd.dev"
      sku                   = "Enterprise"
      filtered_sync_enabled = false
    }
  }
}