resource "aws_cloudwatch_event_rule" "event_rule" {
  for_each = var.event_params

  name           = each.value.name
  event_bus_name = each.value.event_bus_name
  event_pattern  = file("../../modules/CloudWatch/events/patterns/${each.value.event_pattern}.json")
  is_enabled     = each.value.is_enabled
}

resource "aws_cloudwatch_event_target" "event_target" {
  for_each = var.event_params

  arn  = var.created_topic[each.value.target_name].arn
  rule = aws_cloudwatch_event_rule.event_rule[each.value.name].name
}
