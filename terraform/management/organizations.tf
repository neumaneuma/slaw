# Enable AWS Organizations
resource "aws_organizations_organization" "org" {
  feature_set = "ALL" # Enables all features including consolidated billing
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "sso.amazonaws.com",
  ]
  enabled_policy_types = [
    "AISERVICES_OPT_OUT_POLICY",
    "BACKUP_POLICY",
    "RESOURCE_CONTROL_POLICY",
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY"
  ]
}

resource "aws_organizations_organizational_unit" "top_level_ou" {
  for_each  = var.ou_mapping
  name      = each.value
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_account" "security_ou_account" {
  for_each                   = var.security_accounts
  name                       = each.key
  close_on_deletion          = true
  iam_user_access_to_billing = "DENY"
  email                      = each.value
  parent_id                  = aws_organizations_organizational_unit.top_level_ou["Security"].id
}

data "aws_iam_policy_document" "protect_root_and_org" {
  statement {
    effect = "Deny"
    actions = [
      "organizations:LeaveOrganization"
    ]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "protect_root_and_org" {
  name        = "ProtectRootAndOrg"
  description = "Prevent the ability to leave AWS Organizations"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.protect_root_and_org.json
}

resource "aws_organizations_policy_attachment" "protect_root_and_org" {
  policy_id = aws_organizations_policy.protect_root_and_org.id
  target_id = aws_organizations_organization.org.roots[0].id
}

data "aws_iam_policy_document" "restrict_root_user" {
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

resource "aws_organizations_policy" "restrict_root_user" {
  name        = "RestrictRootUser"
  description = "Restrict the root user"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.restrict_root_user.json
}

resource "aws_organizations_policy_attachment" "restrict_root_user" {
  for_each  = { for k, v in aws_organizations_organizational_unit.top_level_ou : k => v if k != "Exceptions" }
  policy_id = aws_organizations_policy.restrict_root_user.id
  target_id = each.value.id
}
