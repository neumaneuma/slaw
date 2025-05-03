provider "aws" {
  region = var.region
}

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

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.main_state.id
  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::992382570951:user/playground",
        "arn:aws:iam::222785560885:role/OrganizationAccountAccessRole"
      ]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.main_state.arn,
      "${aws_s3_bucket.main_state.arn}/*",
    ]
  }
}
