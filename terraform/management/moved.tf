moved {
  from = module.organizations.aws_organizations_organizational_unit.security
  to   = module.organizations.aws_organizations_organizational_unit.security["Security"]
}

moved {
  from = module.organizations.aws_organizations_organizational_unit.security
  to   = module.organizations.aws_organizations_organizational_unit.top_level_ou
}

moved {
  from = module.organizations.aws_organizations_account.security_audit
  to   = module.organizations.aws_organizations_account.security_ou_account
}

moved {
  from = module.organizations.aws_organizations_account.security_ou_account
  to   = module.organizations.aws_organizations_account.security_ou_account["SecurityAudit"]
}

moved {
  from = module.cloudwatch.aws_cloudwatch_metric_alarm.billing_alert
  to   = aws_cloudwatch_metric_alarm.billing_alert
}

moved {
  from = module.cloudwatch.aws_sns_topic_subscription.security_alerts
  to   = aws_sns_topic_subscription.security_alerts
}


moved {
  from = module.cloudtrail.aws_accessanalyzer_analyzer.main
  to   = aws_accessanalyzer_analyzer.main
}

moved {
  from = module.cloudtrail.aws_cloudtrail.audit
  to   = aws_cloudtrail.audit
}
