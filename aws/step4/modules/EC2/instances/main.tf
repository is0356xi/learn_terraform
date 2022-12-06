resource "aws_instance" "instance" {
  for_each = var.ec2_params

  ami                         = each.value.ami
  associate_public_ip_address = "false"
  #   availability_zone           = each.value.availability_zone

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  #   cpu_core_count       = "1"
  #   cpu_threads_per_core = "1"

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_stop        = "false"
  disable_api_termination = "false"
  ebs_optimized           = "false"

  enclave_options {
    enabled = "false"
  }

  get_password_data                    = "false"
  hibernation                          = "false"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = each.value.instance_type
  ipv6_address_count                   = "0"
  key_name                             = each.value.key_name

  maintenance_options {
    auto_recovery = "default"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = "1"
    http_tokens                 = "optional"
    instance_metadata_tags      = "disabled"
  }

  monitoring = "false"

  private_dns_name_options {
    enable_resource_name_dns_a_record    = "true"
    enable_resource_name_dns_aaaa_record = "false"
    hostname_type                        = "ip-name"
  }

  #   private_ip = "10.0.0.94"

  root_block_device {
    delete_on_termination = "true"
    encrypted             = "false"
    volume_size           = "8"
    volume_type           = "gp2"
  }

  source_dest_check = "true"
  subnet_id         = var.created_subnet[each.value.association_subnet].id

  tenancy = "default"
  #   vpc_security_group_ids = ["sg-0b23da7c01a2d645f"]
}
