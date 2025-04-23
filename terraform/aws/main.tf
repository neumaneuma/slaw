terraform {
  backend "s3" {
    bucket       = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key          = "state/aws.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}

resource "random_uuid" "uuid" {}

module "cloudtrail" {
  source      = "../labs/cloudtrail"
  region      = var.region
  trail_name  = "permissions-audit-trail"
  bucket_name = "cloudtrail-audit-logs-${random_uuid.uuid.result}"
}

module "cloudformation" {
  source = "../labs/cloudformation"
  region = "us-east-1"
}

module "cloudformation2" {
  source = "../labs/cloudformation"
  region = "us-west-2"
}

module "cloudwatch" {
  source = "../labs/cloudwatch"
}
