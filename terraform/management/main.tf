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

data "terraform_remote_state" "security_audit" {
  backend = "s3"

  config = {
    bucket = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key    = "state/security-audit.tfstate"
    region = "us-east-1"
  }
}

module "shared" {
  source = "../shared"
}

module "cloudtrail" {
  source          = "../management_modules/cloudtrail"
  region          = var.region
  trail_name      = "permissions-audit-trail"
  bucket_name     = "cloudtrail-audit-logs-${random_uuid.uuid.result}"
  new_bucket_name = data.terraform_remote_state.security_audit.outputs.s3_bucket_name
}

module "cloudformation" {
  source = "../management_modules/cloudformation"
  region = "us-east-1"
}

module "cloudformation2" {
  source = "../management_modules/cloudformation"
  region = "us-west-2"
}

module "cloudwatch" {
  source = "../management_modules/cloudwatch"
}

module "iam" {
  source                   = "../management_modules/iam"
  cloudtrail_s3_bucket_arn = module.cloudtrail.cloudtrail_s3_bucket_arn
}

module "organizations" {
  source = "../management_modules/organizations"
}

module "identitycenter" {
  source                    = "../management_modules/identitycenter"
  management_account_id     = module.shared.account_mapping["management"]
  security_audit_account_id = module.shared.account_mapping["security-audit"]
}
