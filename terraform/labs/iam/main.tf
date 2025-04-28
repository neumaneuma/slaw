terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_instance" {
  name               = "SSMInstance"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ssm_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Necessary to grant role permission to access EC2 instance
# resource "aws_iam_instance_profile" "test_profile" {
#   name = "test_profile"
#   role = aws_iam_role.role.name
# }

data "aws_iam_policy_document" "cloudtrail_rw" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]

    resources = [
      var.cloudtrail_s3_bucket_arn,
    ]
  }
}

resource "aws_iam_policy" "cloudtrail_rw" {
  name        = "CloudtrailReadWrite"
  description = "https://slaw.securosis.com/p/write-simple-iam-policy"
  policy      = data.aws_iam_policy_document.cloudtrail_rw.json
}
