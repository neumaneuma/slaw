terraform {
  backend "s3" {
    bucket       = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key          = "state/security-audit.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "management" {
  backend = "s3"

  config = {
    bucket = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key    = "state/aws.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"

  # force use of the SecurityAudit account's service role OrganizationAccountAccessRole
  assume_role {
    role_arn     = "arn:aws:iam::${module.shared.account_mapping["security-audit"]}:role/OrganizationAccountAccessRole"
    session_name = "tf-security-audit-OrganizationAccountAccessRole"
  }
}

module "shared" {
  source = "../modules/shared"
}


module "guardduty-us-east-1" {
  source                    = "./guardduty"
  region                    = "us-east-1"
  security_audit_account_id = module.shared.account_mapping["security-audit"]
}

module "guardduty-us-west-2" {
  source                    = "./guardduty"
  region                    = "us-west-2"
  security_audit_account_id = module.shared.account_mapping["security-audit"]
}

resource "aws_securityhub_finding_aggregator" "aggregator" {
  linking_mode = "ALL_REGIONS"
}

resource "aws_securityhub_organization_configuration" "org_config" {
  depends_on = [aws_securityhub_finding_aggregator.aggregator]

  # Seems like home region is not configurable, but defaults to the region the provider that applied the changes
  auto_enable           = false
  auto_enable_standards = "NONE"
  organization_configuration {
    configuration_type = "CENTRAL"
  }
}

resource "aws_securityhub_configuration_policy" "config_policy" {
  name = "configuration-policy-01"

  configuration_policy {
    service_enabled       = true
    enabled_standard_arns = []

    security_controls_configuration {
      enabled_control_identifiers = []
    }
  }

  depends_on = [aws_securityhub_organization_configuration.org_config]
}

resource "aws_securityhub_configuration_policy_association" "config_policy_association" {
  target_id = data.terraform_remote_state.management.outputs.root_ou_id
  policy_id = aws_securityhub_configuration_policy.config_policy.id
}
