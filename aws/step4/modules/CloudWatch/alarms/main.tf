resource "aws_cloudwatch_metric_alarm" "metric_alarm" {
  for_each = var.alarm_params

  alarm_name        = each.value.alarm_name
  alarm_description = each.value.alarm_description

  # 評価ルール
  comparison_operator = each.value.comparison_operator
  threshold           = each.value.threshold
  period              = each.value.period
  statistic           = each.value.statistic
  evaluation_periods  = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data

  # 監視対象リソース
  namespace   = each.value.namespace
  metric_name = each.value.metric_name
  dimensions = {
    InstanceId = var.created_instance[each.value.dimensions.InstanceName].id
  }

  # アラーム発行(アクション)
  actions_enabled = each.value.actions_enabled
  ok_actions      = [var.created_topic[each.value.topic_name].arn]
  alarm_actions   = [var.created_topic[each.value.topic_name].arn]
}