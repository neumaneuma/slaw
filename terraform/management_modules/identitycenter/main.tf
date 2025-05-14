data "aws_ssoadmin_instances" "idp" {}

resource "aws_identitystore_group" "this" {
  display_name      = "Administrators"
  description       = "Full admin"
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]
}

resource "aws_identitystore_user" "user1" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]

  display_name = "John Doe"
  user_name    = "johndoe"

  name {
    given_name  = "John"
    family_name = "Doe"
  }

  emails {
    value = "storks-00elders+ssouser1@icloud.com"
  }
}

resource "aws_identitystore_group_membership" "user1" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.idp.identity_store_ids)[0]
  group_id          = aws_identitystore_group.this.group_id
  member_id         = aws_identitystore_user.user1.user_id
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

  principal_id   = aws_identitystore_group.this.group_id
  principal_type = "GROUP"

  target_id   = var.management_account_id
  target_type = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "security_audit_admin_access" {
  instance_arn       = tolist(data.aws_ssoadmin_instances.idp.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin_access.arn

  principal_id   = aws_identitystore_group.this.group_id
  principal_type = "GROUP"

  target_id   = var.security_audit_account_id
  target_type = "AWS_ACCOUNT"
}
