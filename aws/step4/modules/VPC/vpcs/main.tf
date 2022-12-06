/*
terraformerでimportしたresourceブロックをコピペ
*/

resource "aws_vpc" "vpc" {
  for_each = var.vpc_params

  assign_generated_ipv6_cidr_block     = each.value.assign_generated_ipv6_cidr_block
  cidr_block                           = each.value.cidr_block
  enable_classiclink                   = each.value.enable_classiclink
  enable_classiclink_dns_support       = each.value.enable_classiclink_dns_support
  enable_dns_hostnames                 = each.value.enable_dns_hostnames
  enable_dns_support                   = each.value.enable_dns_support
  enable_network_address_usage_metrics = each.value.enable_network_address_usage_metrics
  instance_tenancy                     = each.value.instance_tenancy
  #   ipv6_netmask_length                  = "0"
}