# terraform.tfvarsの変数を読み込み
variable "dc_admin_params" {}
variable "avd_local_admin_params" {}

# 環境固有のパラメータ
variable "env_params" {
  default = {
    name                = "dev"
    location            = "eastus"
    resource_group_name = "avd-rg"
    tag = {
      Name = "from_tf"
    }
  }
}

# サブネットのパラメータ
variable "subnet_params" {
  default = {
    # ホストプール1用サブネット
    Hostpool1_subnet = {
      name             = "Hostpool1_subnet"
      address_prefixes = ["10.0.1.0/24"]
    }

    # ホストプール2用サブネット
    Hostpool2_subnet = {
      name             = "Hostpool2_subnet"
      address_prefixes = ["10.0.2.0/24"]
    },

    # NAT Gateway用サブネット
    AzureNat_subnet = {
      name             = "AzureNat_subnet"
      address_prefixes = ["10.0.3.0/26"]
    }

    # Bation用サブネット
    AzureBastionSubnet = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.3.64/26"]
    }

    # AzureFiles用サブネット
    AzureFiles_subnet = {
      name             = "AzureFiles_subnet"
      address_prefixes = ["10.0.3.128/28"]
    }

    # ExpressRouteやVPN Gateway用サブネット
    GatewaySubnet = {
      name             = "GatewaySubnet"
      address_prefixes = ["10.0.3.144/28"]
    }

    # MasterImage作成用サブネット
    MasterImage_subnet = {
      name             = "MasterImage_subnet"
      address_prefixes = ["10.0.3.160/28"]
    }
  }
}


# AVD基盤のパラメータ
variable "avd_infrastructure_params" {
  default = {
    # ワークスペースのパラメータ
    workspaces = {
      workspace1 = {
        name = "workspace1"
      },
      workspace2 = {
        name = "workspace2"
      }
    }

    # ホストプールのパラメータ
    host_pools = {
      hostpool1 = {
        name                     = "hostpool1"
        type                     = "Pooled"
        maximum_sessions_allowed = 10
        load_balancer_type       = "DepthFirst"
      },
      hostpool2 = {
        name                     = "hostpool2"
        type                     = "Pooled"
        maximum_sessions_allowed = 10
        load_balancer_type       = "DepthFirst"
      },
    }

    rfc3339 = "2022-12-25T16:00:00Z"


    # アプリケーショングループのパラメータ
    application_groups = {
      dag1 = {
        name           = "dag1"
        type           = "Desktop"
        host_pool_name = "hostpool1"
        ws_name        = "workspace1"
      },
      dag2 = {
        name           = "dag2"
        type           = "Desktop"
        host_pool_name = "hostpool2"
        ws_name        = "workspace2"
      }
    }
  }
}


# AVD セッションホストのパラメータ
variable "avd_sessionHost_params" {
  default = {
    # NICのパラメータ
    nic = {
      nic1 = {
        name        = "nic1"
        subnet_name = "Hostpool1_subnet"
      },
      nic2 = {
        name        = "nic2"
        subnet_name = "Hostpool2_subnet"
      }
    }

    # VMのパラメータ
    vm = {
      vm1 = {
        name     = "vm1"
        size     = "Standard_DS2_v2"
        nic_name = "nic1"
      },
      vm2 = {
        name     = "vm2"
        size     = "Standard_DS2_v2"
        nic_name = "nic2"
      }
    }

    # ドメイン参加のパラメータ
    domain_join = {
      join1 = {
        name    = "join1"
        vm_name = "vm1"
      },
      join2 = {
        name    = "join2"
        vm_name = "vm2"
      }
    }

    # 構成管理のパラメータ
    dsc = {
      dsc1 = {
        name           = "dsc1"
        vm_name        = "vm1"
        host_pool_name = "hostpool1"
      },
      dsc2 = {
        name           = "dsc2"
        vm_name        = "vm2"
        host_pool_name = "hostpool2"
      }
    }
  }
}

# AVDグループのパラメータ
variable "avd_group_params" {
  default = {
    wl_xx = {
      name     = "wl_xx"
      dag_name = "dag1"
      role     = "Desktop Virtualization User"
    },
    wl_yy = {
      name     = "wl_yy"
      dag_name = "dag2"
      role     = "Desktop Virtualization User"
    }
  }
}

# storageのパラメータ
variable "storage_params" {
  default = {
    # storageアカウントのパラメータ
    avd_storage = {
      name                     = "avdstorage1224"
      account_tier             = "Standard"
      account_kind             = "StorageV2"
      account_replication_type = "LRS"


      azure_files_authentication = {
        directory_type = "AADDS"
      }

    }

    # storage shareのパラメータ
    fslogix = {
      name  = "fslogix"
      quota = 50
    }

  }
}