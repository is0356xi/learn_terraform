resource "aws_internet_gateway" "igw" {
  for_each = var.igw_params

  vpc_id = var.created_vpc[each.value.association_vpc].id
}

