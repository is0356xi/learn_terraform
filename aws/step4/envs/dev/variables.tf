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
      association_vpc                                = "vpc1" # 関連づけるVPC(vpc_paramsのキー)
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
      association_vpc                                = "vpc1" # 関連づけるVPC(vpc_paramsのキー)
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

# IAMユーザのパラメータ
variable "user_params" {
  default = {
    user1 = {
      name  = "learn_cw_user1"
      group = "learn_cloudwatch"
    },
    user2 = {
      name  = "learn_cw_user2"
      group = "learn_cloudwatch"
    },
    user3 = {
      name  = "learn_cw_user3"
      group = "learn_cloudwatch"
    },
    user4 = {
      name  = "learn_cw_user4"
      group = "learn_cloudwatch"
    },
    user5 = {
      name  = "learn_cw_user5"
      group = "learn_cloudwatch"
    },
    user6 = {
      name  = "learn_cw_user6"
      group = "learn_cloudwatch"
    },
    user7 = {
      name  = "learn_cw_user7"
      group = "learn_cloudwatch"
    },
    user8 = {
      name  = "learn_cw_user8"
      group = "learn_cloudwatch"
    }
  }
}

# IAMグループのパラメータ
variable "group_params" {
  default = {
    learn_cloudwatch = {
      name   = "learn_cloudwatch"
      path   = "/" # グループが作られる階層を指定する
      policy = "CloudWatchReadOnly"
    }
  }
}


# EC2インスタンスのパラメータ
variable "ec2_params" {
  default = {
    cw_test_ec2 = {
      name               = "cw_test_ec2"
      association_subnet = "subnet1"
      ami                = "ami-072bfb8ae2c884cc4"
      # availability_zone = "ap-northeast-1d"
      instance_type = "t2.micro"
      key_name      = "sakue103"
    }
  }
}


# SNSトピックのパラメータ
variable "topic_params" {
  default = {
    v1_cloudwatch_topic = {
      name                                     = "v1_cloudwatch_topic"
      application_success_feedback_sample_rate = "0"
      content_based_deduplication              = "false"
      fifo_topic                               = "false"
      firehose_success_feedback_sample_rate    = "0"
      http_success_feedback_sample_rate        = "0"
      lambda_success_feedback_sample_rate      = "0"
    }
  }
}


# SNSトピック サブスクリプションのパラメータ
variable "subscription_params" {
  default = {
    cloudwatch_subscription = {
      topic_name = "v1_cloudwatch_topic"
      protocol   = "email"
      # endpoint = <your email address>
    }
  }
}

/*
protcolがemailの場合、endpoint=メールアドレスとなる。
センシティブデータ扱いでterraform.tfvarsに記載する。
*/
variable "endpoints" {} # endpoint=メールアドレスとなる。apply時にtfvarsから受け取る


# CloudWatchアラームのパラメータ
variable "alarm_params" {
  default = {
    ec2_cpu_alarm = {
      alarm_name        = "ec2_cpu_alarm"
      alarm_description = "・CPU使用率の最大値を基に、OK/Alarmを判定する\n・5分間隔で評価\n・2/3のデータが閾値を超えている場合、Alarm状態とする"

      # 評価ルール
      comparison_operator = "GreaterThanOrEqualToThreshold"
      threshold           = "50"
      period              = "300"
      statistic           = "Maximum"
      evaluation_periods  = "3"
      datapoints_to_alarm = "2"
      treat_missing_data  = "missing"

      # 監視対象
      namespace   = "AWS/EC2"
      metric_name = "CPUUtilization"
      dimensions = {
        InstanceName = "cw_test_ec2"
      }

      # アラーム発行(アクション)
      topic_name      = "v1_cloudwatch_topic"
      actions_enabled = "true"
    }
  }
}

# CloudWatchイベント (EventBridge)のパラメータ
variable "event_params" {
  default = {
    ec2_state_change = {
      name           = "ec2_state_change"
      event_bus_name = "default"
      event_pattern  = "State-change-Notification"
      is_enabled     = "true"
      target_name    = "v1_cloudwatch_topic"
    }
  }
}
