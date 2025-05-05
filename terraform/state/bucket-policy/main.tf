resource "aws_s3_bucket_policy" "policy" {
  bucket = var.state_bucket_id
  policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid = "ListContentsOfStateBucket"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:role/OrganizationAccountAccessRole"
      ]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      var.state_bucket_arn
    ]
  }

  statement {
    sid = "FullPermissionsOverOwnStateFile"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:role/OrganizationAccountAccessRole"
      ]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "${var.state_bucket_arn}/state/${var.state_file_name}.tfstate",
      "${var.state_bucket_arn}/state/${var.state_file_name}.tfstate.tflock",
    ]
  }

  statement {
    sid = "ManagementAccountReadAccess"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_id}:role/OrganizationAccountAccessRole"
      ]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${var.state_bucket_arn}/state/aws.tfstate",
    ]
  }
}
