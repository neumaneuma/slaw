terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region

  # force use of the SecurityAudit account's service role OrganizationAccountAccessRole
  assume_role {
    role_arn     = var.role_arn
    session_name = var.session_name
  }
}

resource "aws_guardduty_detector" "detector" {
  enable = true
}

# initially was in a weird state with this error because i had some mixup in enabling guardduty delegated admin from all the right regions in the management account, and actually enabling guardduty using the security-audit member account instead of the management account │ Error: updating GuardDuty Organization Configuration (eecb77edbcc1ab393f023fedea930c06): operation error GuardDuty: UpdateOrganizationConfiguration, https response error StatusCode: 400, RequestID: bd75f2bb-dbfb-4d76-a9d0-4c98a6ff97fc, BadRequestException: The request is rejected because an invalid or out-of-range value is specified as an input parameter.
resource "aws_guardduty_organization_configuration" "config" {
  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.detector.id
}

output "guardduty_detector_id" {
  value = aws_guardduty_detector.detector.id
}

data "aws_region" "current" {}

output "provider_region" {
  value = data.aws_region.current.name
}
