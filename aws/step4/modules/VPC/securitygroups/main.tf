resource "aws_security_group" "security_group" {
  for_each = var.sg_params

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.created_vpc[each.value.vpc_name].id


  dynamic "ingress" {
    for_each = each.value.rules_ingress
    content {
      description = ingress.key
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}