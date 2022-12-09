resource "aws_route_table" "route_table" {
  for_each = var.route_table_params

  vpc_id = var.created_vpc[each.value.vpc_name].id

  dynamic "route" {
    for_each = each.value.routes
    content {
      cidr_block = route.value.destination

      # type_dstによって、next_hopの種類を判定する
      gateway_id  = route.value.type_dst == "gateway" ? var.dst_resources["gateway"][route.value.next_hop].id : null
      instance_id = route.value.type_dst == "instance" ? var.dst_resources["instance"][route.value.next_hop].id : null
    }
  }
}


resource "aws_route_table_association" "route_association" {
  for_each = var.route_table_params

  route_table_id = aws_route_table.route_table[each.value.name].id
  subnet_id      = var.created_subnet[each.value.subnet_name].id
}