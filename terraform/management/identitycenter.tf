data "aws_ssoadmin_instances" "idp" {}

resource "aws_identitystore_group" "administrators" {
  display_name      = "Administrators"
  description       = "Full admin"
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]
}

resource "aws_identitystore_user" "sso_user" {
  for_each          = var.sso_admin_users
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]

  user_name    = each.key
  display_name = each.value.display_name

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value = each.value.email
  }
}

resource "aws_identitystore_group_membership" "sso_user" {
  for_each          = var.sso_admin_users
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]
  group_id          = aws_identitystore_group.administrators.group_id
  member_id         = aws_identitystore_user.sso_user[each.key].user_id
}

resource "aws_ssoadmin_permission_set" "admin_access" {
  name         = "AdministratorAccess"
  description  = "Full admin"
  instance_arn = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
}

resource "aws_ssoadmin_managed_policy_attachment" "admin_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn
}

resource "aws_ssoadmin_account_assignment" "management_admin_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  principal_id   = aws_identitystore_group.administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["management"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "log_archive_admin_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  principal_id   = aws_identitystore_group.administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["log-archive"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_audit1_admin_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  principal_id   = aws_identitystore_group.administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["security-audit"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_operations_admin_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  principal_id   = aws_identitystore_group.administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["security-operations"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "iam_admin_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  principal_id   = aws_identitystore_group.administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["iam"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "test_account1_admin_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  principal_id   = aws_identitystore_group.administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["test-account1"]
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "system_design_admin_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  principal_id   = aws_identitystore_group.administrators.group_id
  principal_type = "GROUP"

  target_id   = module.shared.account_mapping["system-design"]
  target_type = "AWS_ACCOUNT"
}
