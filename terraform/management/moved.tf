# https://developer.hashicorp.com/terraform/language/modules/develop/refactoring

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

moved {
  from = module.iam.aws_iam_role.ssm_instance
  to   = aws_iam_role.ssm_instance
}

moved {
  from = module.iam.aws_iam_role_policy_attachment.ssm_managed
  to   = aws_iam_role_policy_attachment.ssm_managed
}

moved {
  from = module.organizations.aws_organizations_account.security_ou_account["SecurityAudit"]
  to   = aws_organizations_account.security_ou_account["SecurityAudit"]
}

moved {
  from = module.organizations.aws_organizations_organization.org
  to   = aws_organizations_organization.org
}

moved {
  from = module.organizations.aws_organizations_organizational_unit.top_level_ou["Security"]
  to   = aws_organizations_organizational_unit.top_level_ou["Security"]
}

moved {
  from = module.organizations.aws_organizations_policy.protect_root_and_org
  to   = aws_organizations_policy.protect_root_and_org
}

moved {
  from = module.organizations.aws_organizations_policy_attachment.protect_root_and_org
  to   = aws_organizations_policy_attachment.protect_root_and_org
}

moved {
  from = module.identitycenter.aws_identitystore_group.this
  to   = aws_identitystore_group.administrators
}

moved {
  from = module.identitycenter.aws_identitystore_group.this
  to   = aws_identitystore_group.administrators
}

moved {
  from = module.identitycenter.aws_identitystore_group_membership.user1
  to   = aws_identitystore_group_membership.sso_user["johndoe"]
}

moved {
  from = module.identitycenter.aws_identitystore_user.user1
  to   = aws_identitystore_user.sso_user["johndoe"]
}

moved {
  from = module.identitycenter.aws_ssoadmin_account_assignment.management_admin_access
  to   = aws_ssoadmin_account_assignment.management_admin_access
}

moved {
  from = module.identitycenter.aws_ssoadmin_account_assignment.security_audit_admin_access
  to   = aws_ssoadmin_account_assignment.security_audit_admin_access
}

moved {
  from = module.identitycenter.aws_ssoadmin_managed_policy_attachment.admin_access
  to   = aws_ssoadmin_managed_policy_attachment.admin_access
}

moved {
  from = module.identitycenter.aws_ssoadmin_permission_set.admin_access
  to   = aws_ssoadmin_permission_set.admin_access
}
