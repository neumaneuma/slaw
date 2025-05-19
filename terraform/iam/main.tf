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

# Groups and their membership

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

# Permission sets and their account + group couplings. The `aws_ssoadmin_account_assignment`
# resource will follow the naming pattern of <group>_<permission_set>_<account>

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

resource "aws_ssoadmin_account_assignment" "iam_administrator_identity_center_administration_iam" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.identity_center_administration.arn

  principal_id   = aws_identitystore_group.iam_administrator.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["iam"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set" "read_only_access" {
  name             = "ReadOnlyAccess"
  instance_arn     = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  session_duration = "PT1H" # 1 hour session
}

resource "aws_ssoadmin_managed_policy_attachment" "read_only_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.read_only_access.arn
}

resource "aws_ssoadmin_account_assignment" "security_administrators_read_only_access_log_archive" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.read_only_access.arn

  principal_id   = aws_identitystore_group.security_administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["log-archive"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_administrators_read_only_access_security_audit" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.read_only_access.arn

  principal_id   = aws_identitystore_group.security_administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["security-audit"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_administrators_read_only_access_security_operations" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.read_only_access.arn

  principal_id   = aws_identitystore_group.security_administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["security-operations"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_administrators_read_only_access_test_account1" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.read_only_access.arn

  principal_id   = aws_identitystore_group.security_administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["test-account1"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set" "security_full_admin" {
  name             = "SecurityFullAdmin"
  instance_arn     = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  session_duration = "PT1H" # 1 hour session
}

resource "aws_ssoadmin_managed_policy_attachment" "security_full_admin" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.security_full_admin.arn
}

resource "aws_ssoadmin_account_assignment" "security_administrators_security_full_admin_log_archive" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.security_full_admin.arn

  principal_id   = aws_identitystore_group.security_administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["log-archive"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_administrators_security_full_admin_security_audit" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.security_full_admin.arn

  principal_id   = aws_identitystore_group.security_administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["security-audit"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_administrators_security_full_admin_security_operations" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.security_full_admin.arn

  principal_id   = aws_identitystore_group.security_administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["security-operations"]
  target_type = "AWS_ACCOUNT"
}
