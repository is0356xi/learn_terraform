resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  for_each = var.subscription_params

  topic_arn = var.created_topic[each.value.topic_name].arn
  protocol  = each.value.protocol
  endpoint  = var.endpoints[each.value.topic_name]
}