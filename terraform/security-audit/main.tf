terraform {
  backend "s3" {
    bucket       = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key          = "state/security-audit.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

resource "random_uuid" "uuid" {}

module "shared" {
  source = "../shared"
}

data "terraform_remote_state" "management" {
  backend = "s3"

  config = {
    bucket = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key    = "state/aws.tfstate"
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "cloudtrail-audit-logs-${random_uuid.uuid.result}"
}

resource "aws_s3_bucket_public_access_block" "bpa" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_public_access" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.policy.json
}

# https://slaw.securosis.com/p/secure-bucket-centralized-logging-part-2-resource-policies
# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html
data "aws_iam_policy_document" "policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck20150319"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [data.terraform_remote_state.management.outputs.cloudtrail_arn]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite20150319"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/AWSLogs/${module.shared.account_mapping["management"]}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    # The conditionals are necessary to prevent a confused deputy problem. This prevents someone else from using their aws account's cloudtrail to write to our bucket (which could be an economic denial of service).
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [data.terraform_remote_state.management.outputs.cloudtrail_arn]
    }
  }

  statement {
    sid    = "AWSCloudTrailOrganizationWrite20150319"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/AWSLogs/${data.terraform_remote_state.management.outputs.organization_id}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [data.terraform_remote_state.management.outputs.cloudtrail_arn]
    }
  }
}
