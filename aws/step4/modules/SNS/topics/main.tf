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

