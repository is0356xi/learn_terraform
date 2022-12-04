# terraform.tfvarsから読み込み
variable "aws_access_key" {}
variable "aws_secret_key" {}

# 環境固有の変数
variable "env_params" {
  default = {
    name   = "dev"
    region = "ap-northeast-1"
    tags = {
      Name = "from_tf"
    }
  }
}


#VPCのパラメータ
variable "vpc_params" {
  default = {
    vpc1 = {
    assign_generated_ipv6_cidr_block     = "false"
    cidr_block                           = "10.0.0.0/22"
    enable_classiclink                   = "false"
    enable_classiclink_dns_support       = "false"
    enable_dns_hostnames                 = "false"
    enable_dns_support                   = "true"
    enable_network_address_usage_metrics = "false"
    instance_tenancy                     = "default"
  }
  }
}


# サブネットのパラメータ
variable "subnet_params" {
  default = {
    subnet1 = {
      association_vpc = "vpc1"  # 関連づけるVPC(vpc_paramsのキー)
      assign_ipv6_address_on_creation                = "false"
      cidr_block                                     = "10.0.0.0/24"
      enable_dns64                                   = "false"
      enable_resource_name_dns_a_record_on_launch    = "false"
      enable_resource_name_dns_aaaa_record_on_launch = "false"
      ipv6_native                                    = "false"
      map_customer_owned_ip_on_launch                = "false"
      map_public_ip_on_launch                        = "false"
      private_dns_hostname_type_on_launch            = "ip-name"
    },

    subnet2 = {
      association_vpc = "vpc1"  # 関連づけるVPC(vpc_paramsのキー)
      assign_ipv6_address_on_creation                = "false"
      cidr_block                                     = "10.0.1.0/24"
      enable_dns64                                   = "false"
      enable_resource_name_dns_a_record_on_launch    = "false"
      enable_resource_name_dns_aaaa_record_on_launch = "false"
      ipv6_native                                    = "false"
      map_customer_owned_ip_on_launch                = "false"
      map_public_ip_on_launch                        = "false"
      private_dns_hostname_type_on_launch            = "ip-name"
    }
  }
}
