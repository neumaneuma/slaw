terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Enable AWS Organizations
resource "aws_organizations_organization" "org" {
  feature_set = "ALL" # Enables all features including consolidated billing
  enabled_policy_types = [
    "AISERVICES_OPT_OUT_POLICY", "BACKUP_POLICY", "RESOURCE_CONTROL_POLICY", "SERVICE_CONTROL_POLICY", "TAG_POLICY"
  ]
}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_account" "security_audit" {
  name                       = "SecurityAudit"
  close_on_deletion          = true
  iam_user_access_to_billing = "DENY"
  email                      = "storks-00elders+security_audit@icloud.com"
  parent_id                  = aws_organizations_organizational_unit.security.id
}

data "aws_iam_policy_document" "protect_root_and_org" {
  statement {
    effect = "Deny"
    actions = [
      "organizations:LeaveOrganization"
    ]
    resources = ["*"]
  }

  # Deny any action taken by the root user
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

resource "aws_organizations_policy" "protect_root_and_org" {
  name        = "ProtectRootAndOrg"
  description = "Restrict the root account and the ability to leave AWS Organizations"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.protect_root_and_org.json
}

resource "aws_organizations_policy_attachment" "protect_root_and_org" {
  policy_id = aws_organizations_policy.protect_root_and_org.id
  target_id = aws_organizations_organization.org.roots[0].id
}
