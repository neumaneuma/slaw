provider "aws" {
  region = var.region
}

module "shared" {
  source = "../shared"
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

# Give each account (via their root module) full control over their own state file (but not the full state bucket or other state files)
module "bucket_policy" {
  source = "./bucket-policy"

  state_bucket_id  = aws_s3_bucket.main_state.id
  state_bucket_arn = aws_s3_bucket.main_state.arn
  state_file_name  = "log-archive"
  account_id       = module.shared.account_mapping["log-archive"]
}
