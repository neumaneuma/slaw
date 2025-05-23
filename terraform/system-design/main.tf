terraform {
  backend "s3" {
    bucket       = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key          = "state/system-design.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"

  # force use of the SystemDesign account's service role OrganizationAccountAccessRole
  assume_role {
    role_arn     = "arn:aws:iam::${module.shared.account_mapping["system-design"]}:role/OrganizationAccountAccessRole"
    session_name = "tf-system-design-OrganizationAccountAccessRole"
  }
}

module "shared" {
  source = "../modules/shared"
}

resource "random_uuid" "random_uuid" {}

resource "aws_s3_bucket" "bucket" {
  bucket = "test-bucket-${random_uuid.random_uuid.result}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.external_user_file_storage_role.arn
      ]
    }

    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*"
    ]
  }
}

resource "aws_iam_user" "external_user_file_storage_user" {
  name = "external_user_file_storage_user"
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.external_user_file_storage_user.arn]
    }
  }
}

resource "aws_iam_role" "external_user_file_storage_role" {
  name               = "external_user_file_storage_role"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

# resource "aws_dynamodb_resource_policy" "secret_store" {
#   resource_arn = aws_dynamodb_table.secret_store.arn
#   policy       = data.aws_iam_policy_document.test.json
# }
