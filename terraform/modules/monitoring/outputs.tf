output "cloudwatch_log_group_app" {
  value = aws_cloudwatch_log_group.app.name
}

output "cloudwatch_log_group_bastion" {
  value = aws_cloudwatch_log_group.bastion.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
