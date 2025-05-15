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
