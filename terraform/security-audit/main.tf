terraform {
  backend "s3" {
    bucket       = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key          = "state/security-audit.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

data "aws_caller_identity" "current" {}

module "shared" {
  source = "../modules/shared"
}

locals {
  role_arn     = "arn:aws:iam::${module.shared.account_mapping["security-audit"]}:role/OrganizationAccountAccessRole"
  session_name = "tf-security-audit-OrganizationAccountAccessRole"
}

module "guardduty-us-east-1" {
  source       = "./guardduty"
  region       = "us-east-1"
  role_arn     = local.role_arn
  session_name = local.session_name
}

module "guardduty-us-west-2" {
  source       = "./guardduty"
  region       = "us-west-2"
  role_arn     = local.role_arn
  session_name = local.session_name
}
