resource "aws_subnet" "subnets" {
  for_each = var.subnet_params

  assign_ipv6_address_on_creation                = each.value.assign_ipv6_address_on_creation
  cidr_block                                     = each.value.cidr_block
  enable_dns64                                   = each.value.enable_dns64
  enable_resource_name_dns_a_record_on_launch    = each.value.enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = each.value.enable_resource_name_dns_aaaa_record_on_launch
  ipv6_native                                    = each.value.ipv6_native
  # map_customer_owned_ip_on_launch                = each.value.map_customer_owned_ip_on_launch
  map_public_ip_on_launch             = each.value.map_public_ip_on_launch
  private_dns_hostname_type_on_launch = each.value.private_dns_hostname_type_on_launch

  vpc_id = var.created_vpc[each.value.association_vpc].id
}
