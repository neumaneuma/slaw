provider "aws" {
  region = var.region
}

module "shared" {
  source = "../modules/shared"
}

data "aws_caller_identity" "current" {}

resource "random_uuid" "uuid" {
}

resource "aws_s3_bucket" "main_state" {
  bucket = "main-state-${random_uuid.uuid.result}"
}

resource "aws_s3_bucket_versioning" "main_state" {
  bucket = aws_s3_bucket.main_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main_state" {
  bucket = aws_s3_bucket.main_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main_state" {
  bucket = aws_s3_bucket.main_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

locals {
  all_member_account_root_modules = {
    "security-audit" = module.shared.account_mapping["security-audit"],
    "iam"            = module.shared.account_mapping["iam"],
    "log-archive"    = module.shared.account_mapping["log-archive"],
    "system-design"  = module.shared.account_mapping["system-design"],
  }
  # the member accounts that need access to the data resource "terraform_remote_state" for the management account state file
  member_accounts_that_need_read_access_to_management_account_state_file = {
    "log-archive"    = module.shared.account_mapping["log-archive"],
    "security-audit" = module.shared.account_mapping["security-audit"],
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.main_state.id
  policy = data.aws_iam_policy_document.combine_all_policies.json
}

data "aws_iam_policy_document" "combine_all_policies" {
  override_policy_documents = concat(
    [for doc in data.aws_iam_policy_document.give_each_account_control_over_own_state_file : doc.json],
    [for doc in data.aws_iam_policy_document.give_some_member_accounts_read_access_to_management_account_state_file : doc.json],
  )
}

# Give each account (via their root module) full control over their own state file (but not the full state bucket or other state files)
data "aws_iam_policy_document" "give_each_account_control_over_own_state_file" {
  for_each = local.all_member_account_root_modules
  statement {
    sid = "ListContentsOfStateBucket-${each.key}"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${each.value}:role/OrganizationAccountAccessRole"
      ]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.main_state.arn
    ]
  }

  statement {
    sid = "FullPermissionsOverOwnStateFile-${each.key}"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${each.value}:role/OrganizationAccountAccessRole"
      ]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.main_state.arn}/state/${each.key}.tfstate",
      "${aws_s3_bucket.main_state.arn}/state/${each.key}.tfstate.tflock",
    ]
  }
}

# Only some accounts need read access to the management account state file
data "aws_iam_policy_document" "give_some_member_accounts_read_access_to_management_account_state_file" {
  for_each = local.member_accounts_that_need_read_access_to_management_account_state_file
  statement {
    sid = "ManagementAccountReadAccess-${each.key}"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${each.value}:role/OrganizationAccountAccessRole"
      ]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.main_state.arn}/state/aws.tfstate",
    ]
  }
}
