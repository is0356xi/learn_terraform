/*
module呼び出しテンプレート

module <module名>{
  source = "../../modules/<moduleのpath>"
  env_params = var.env_params

  # 以下、モジュールに渡す変数群
}
*/


######  network作成  ######

module "vpc" {
  source     = "../../modules/VPC/vpcs"
  env_params = var.env_params

  vpc_params = var.vpc_params
}

module "subnet" {
  source     = "../../modules/VPC/subnets"
  env_params = var.env_params

  subnet_params = var.subnet_params
  created_vpc   = module.vpc.created_vpc

  depends_on = [module.vpc]
}


# ######  IAM関連リソースの作成  ######
module "iam_user" {
  source     = "../../modules/IAM/users"
  env_params = var.env_params

  user_params = var.user_params
}

module "iam_group" {
  source     = "../../modules/IAM/groups"
  env_params = var.env_params

  group_params = var.group_params
  user_params  = var.user_params

  depends_on = [module.iam_user]
}

# ログインパスワードを出力
output "passwords" {
  # zipmap([a,b], [c,d]) --> {a=b, c=d}
  value = zipmap(module.iam_user.created_iam_user, module.iam_user.encrypted_password)
}

# アクセスキーを出力
output "access_keys" {
  value = zipmap(module.iam_user.created_iam_user, module.iam_user.encrypted_secret)
}


##### EC2 #####
module "ec2_instance" {
  source     = "../../modules/EC2/instances"
  env_params = var.env_params

  created_subnet = module.subnet.created_subnet

  ec2_params = var.ec2_params

  depends_on = [module.subnet]
}

##### SNS #####
module "sns_topic" {
  source     = "../../modules/SNS/topics"
  env_params = var.env_params

  topic_params = var.topic_params
}

module "sns_subscription" {
  source     = "../../modules/SNS/subscriptions"
  env_params = var.env_params

  created_topic       = module.sns_topic.created_topic
  subscription_params = var.subscription_params
  endpoints           = var.endpoints

  depends_on = [module.sns_topic]
}


##### CloudWatch #####
module "alarm" {
  source     = "../../modules/CloudWatch/alarms"
  env_params = var.env_params

  created_topic    = module.sns_topic.created_topic
  created_instance = module.ec2_instance.created_instance
  alarm_params     = var.alarm_params

  depends_on = [module.sns_topic]
}

module "event" {
  source     = "../../modules/CloudWatch/events"
  env_params = var.env_params

  created_topic = module.sns_topic.created_topic
  event_params  = var.event_params

  depends_on = [module.sns_topic]
}



##### デバッグ #####
output "debug" {
  value = {
    # created_vpc = module.vpc.created_vpc,
    # created_subnet = module.subnet.created_subnet
    created_instance = module.ec2_instance.created_instance
    # created_iam_group = module.iam_group.created_iam_group
    # created_iam_user = module.iam_user.created_iam_user
    # creted_topic = module.sns_topic.created_topic
  }
}