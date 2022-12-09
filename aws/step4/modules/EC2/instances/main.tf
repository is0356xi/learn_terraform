resource "aws_instance" "instance" {
  for_each = var.ec2_params

  ami                         = each.value.ami
  associate_public_ip_address = each.value.associate_public_ip_address
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
  subnet_id         = var.created_subnet[each.value.subnet_name].id


  tenancy = "default"
  /*
  security_group_namasに含まれるSG名をキーとして、作成済みSGからidを取得
  ・三項演算子を使用  [for 変数名 in リスト: 変数名を使った処理] → 処理後の値がリストに格納されていく
  */
  vpc_security_group_ids = [
    for sg_name in each.value.security_group_names : var.created_sg[sg_name].id
  ]
}
