terraform {
  backend "s3" {
    bucket       = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key          = "state/iam.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

  # force use of the IAM account's service role OrganizationAccountAccessRole
  assume_role {
    role_arn     = "arn:aws:iam::${module.shared.account_mapping["iam"]}:role/OrganizationAccountAccessRole"
    session_name = "tf-iam-OrganizationAccountAccessRole"
  }
}

data "aws_caller_identity" "current" {}

data "aws_ssoadmin_instances" "idp" {}

module "shared" {
  source = "../shared"
}

resource "aws_identitystore_group" "security_administrators" {
  display_name      = "Security Administrators"
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]
}

resource "aws_identitystore_group_membership" "security_administrators" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]
  group_id          = aws_identitystore_group.security_administrators.group_id
  member_id         = module.shared.sso_user_ids["johndoe"]
}

resource "aws_identitystore_group" "iam_administrator" {
  display_name      = "IAM Administrator"
  description       = "Can administer Identity Center"
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]
}

resource "aws_identitystore_group_membership" "iam_administrator" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]
  group_id          = aws_identitystore_group.iam_administrator.group_id
  member_id         = module.shared.sso_user_ids["johndoe"]
}

resource "aws_ssoadmin_permission_set" "read_only_access" {
  name             = "ReadOnlyAccess"
  instance_arn     = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  session_duration = "PT1H" # 1 hour session
}

resource "aws_ssoadmin_permission_set" "identity_center_administration" {
  name             = "IdentityCenterAdministration"
  description      = "Administer AWS IAM Identity Center from a delegated administration account"
  instance_arn     = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  session_duration = "PT1H" # 1 hour session
}

resource "aws_ssoadmin_managed_policy_attachment" "identity_center_administration" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AWSSSOMemberAccountAdministrator"
  permission_set_arn = aws_ssoadmin_permission_set.identity_center_administration.arn
}
