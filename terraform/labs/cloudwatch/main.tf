terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "billing_alert" {
  alarm_name          = "BillingAlert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600 # 6 hours
  statistic           = "Maximum"
  threshold           = 25
  alarm_description   = "Billing alert"
}

data "aws_sns_topic" "security_alerts" {
  name = "SecurityAlerts"
}

resource "aws_sns_topic_subscription" "security_alerts" {
  topic_arn = data.aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = "storks-00elders@icloud.com"
}
