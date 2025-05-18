# Enable AWS Organizations
resource "aws_organizations_organization" "org" {
  feature_set = "ALL" # Enables all features including consolidated billing
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "sso.amazonaws.com", "account.amazonaws.com",
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

resource "aws_organizations_organizational_unit" "workloads_sub_ou" {
  for_each  = toset(var.workloads_ous)
  name      = each.value
  parent_id = aws_organizations_organizational_unit.top_level_ou["Workloads"].id
}

resource "aws_organizations_account" "nonprod_ou_account" {
  for_each                   = var.nonprod_accounts
  name                       = each.key
  close_on_deletion          = true
  iam_user_access_to_billing = "DENY"
  email                      = each.value
  parent_id                  = aws_organizations_organizational_unit.workloads_sub_ou["NonProd"].id
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

# https://slaw.securosis.com/p/notwhat-lock-regions-double-negative-scp
data "aws_iam_policy_document" "region_lockout" {
  statement {
    sid    = "RegionLockout"
    effect = "Deny"
    not_actions = [
      "a4b:*",
      "acm:*",
      "aws-marketplace-management:*",
      "aws-marketplace:*",
      "aws-portal:*",
      "budgets:*",
      "ce:*",
      "chime:*",
      "cloudfront:*",
      "config:*",
      "cur:*",
      "directconnect:*",
      "ec2:DescribeRegions",
      "ec2:DescribeTransitGateways",
      "ec2:DescribeVpnGateways",
      "fms:*",
      "globalaccelerator:*",
      "health:*",
      "iam:*",
      "importexport:*",
      "kms:*",
      "mobileanalytics:*",
      "networkmanager:*",
      "organizations:*",
      "pricing:*",
      "route53:*",
      "route53domains:*",
      "route53-recovery-cluster:*",
      "route53-recovery-control-config:*",
      "route53-recovery-readiness:*",
      "s3:GetAccountPublic*",
      "s3:ListAllMyBuckets",
      "s3:ListMultiRegionAccessPoints",
      "s3:PutAccountPublic*",
      "shield:*",
      "sts:*",
      "support:*",
      "trustedadvisor:*",
      "waf-regional:*",
      "waf:*",
      "wafv2:*",
      "wellarchitected:*"
    ]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1", "us-west-2"]
    }
  }
}

resource "aws_organizations_policy" "region_lockout" {
  name        = "RegionLockout"
  description = "Deny all actions outside of us-east-1 and us-west-2, except for global services"
  type        = "SERVICE_CONTROL_POLICY"
  content     = data.aws_iam_policy_document.region_lockout.json
}

resource "aws_organizations_policy_attachment" "region_lockout" {
  policy_id = aws_organizations_policy.region_lockout.id
  target_id = aws_organizations_organization.org.roots[0].id
}

locals {
  alternate_contact_types = toset([
    "BILLING",
    "OPERATIONS",
    "SECURITY"
  ])
}

resource "aws_account_alternate_contact" "operations" {
  for_each               = local.alternate_contact_types
  alternate_contact_type = each.value
  # https://docs.aws.amazon.com/accounts/latest/reference/API_PutAlternateContact.html#accounts-PutAlternateContact-permissions
  # > The management account can't specify its own AccountId; it must call the operation in standalone context by not including the AccountId parameter.
  # account_id = module.shared.account_mapping["management"]
  name          = "Bob Bobson"
  title         = "CBO"
  email_address = "storks-00elders+${lower(each.value)}@icloud.com"
  phone_number  = "+1234567890"
}
