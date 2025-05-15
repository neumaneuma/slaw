data "terraform_remote_state" "security_audit" {
  backend = "s3"

  config = {
    bucket = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key    = "state/security-audit.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "audit" {
  name                          = var.trail_name
  s3_bucket_name                = data.terraform_remote_state.security_audit.outputs.s3_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
}

resource "aws_accessanalyzer_analyzer" "main" {
  analyzer_name = "permissions-analyzer"
  type          = "ACCOUNT"
}

# # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html
# data "aws_iam_policy_document" "audit_logs" {
#   statement {
#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }

#     actions   = ["s3:GetBucketAcl"]
#     resources = [aws_s3_bucket.audit_logs.arn]

#     condition {
#       test     = "StringEquals"
#       variable = "aws:SourceArn"
#       values   = ["arn:aws:cloudtrail:${var.region}:${data.aws_caller_identity.current.account_id}:trail/${var.trail_name}"]
#     }
#   }

#   statement {
#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }

#     actions   = ["s3:PutObject"]
#     resources = ["${aws_s3_bucket.audit_logs.arn}/*"]

#     condition {
#       test     = "StringEquals"
#       variable = "s3:x-amz-acl"
#       values   = ["bucket-owner-full-control"]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:SourceArn"
#       values   = ["arn:aws:cloudtrail:${var.region}:${data.aws_caller_identity.current.account_id}:trail/${var.trail_name}"]
#     }
#   }
# }

# # maybe can delete after https://slaw.securosis.com/p/enabling-org-trail-centralized-logging-part-3?
# resource "aws_s3_bucket" "audit_logs" {
#   bucket = var.bucket_name
# }

# resource "aws_s3_bucket_lifecycle_configuration" "logs_cleanup" {
#   bucket = aws_s3_bucket.audit_logs.id

#   rule {
#     id     = "cleanup"
#     status = "Enabled"

#     filter {
#       prefix = "" # empty prefix means apply to all objects
#     }

#     expiration {
#       days = 90
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "audit_logs" {
#   bucket = aws_s3_bucket.audit_logs.id
#   policy = data.aws_iam_policy_document.audit_logs.json
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "audit_logs" {
#   bucket = aws_s3_bucket.audit_logs.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket_public_access_block" "audit_logs" {
#   bucket = aws_s3_bucket.audit_logs.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
