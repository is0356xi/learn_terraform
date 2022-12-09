resource "aws_sns_topic" "sns_topic" {
  for_each = var.topic_params

  name                                     = each.value.name
  application_success_feedback_sample_rate = each.value.application_success_feedback_sample_rate
  content_based_deduplication              = each.value.content_based_deduplication
  fifo_topic                               = each.value.fifo_topic
  firehose_success_feedback_sample_rate    = each.value.firehose_success_feedback_sample_rate
  http_success_feedback_sample_rate        = each.value.http_success_feedback_sample_rate
  lambda_success_feedback_sample_rate      = each.value.lambda_success_feedback_sample_rate
}


# SNSトピックにポリシーを追加 (EventBridgeにSNSへのパブリッシュを許可する)
resource "aws_sns_topic_policy" "topic_policy" {
  for_each = var.topic_params

  arn = aws_sns_topic.sns_topic[each.value.name].arn

  # template_fileで作成されるjsonファイルを参照・代入
  policy = data.template_file.sns_policy[each.value.name].rendered
}



###########  jsonファイルで定義されたSNSトピックのポリシーを上書き  #################
data "template_file" "sns_policy" {
  for_each = var.topic_params

  template = file("../../modules/IAM/policy/${each.value.policy_name}.json")
  vars = {
    owner     = aws_sns_topic.sns_topic[each.value.name].owner
    arn_topic = aws_sns_topic.sns_topic[each.value.name].arn
  }
}