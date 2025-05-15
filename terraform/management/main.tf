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

module "shared" {
  source = "../shared"
}

module "cloudformation" {
  source = "../management_modules/cloudformation"
  region = "us-east-1"
}

module "cloudformation2" {
  source = "../management_modules/cloudformation"
  region = "us-west-2"
}

module "organizations" {
  source            = "../management_modules/organizations"
  ou_mapping        = var.ou_mapping
  security_accounts = var.security_accounts
}

module "identitycenter" {
  source                    = "../management_modules/identitycenter"
  management_account_id     = module.shared.account_mapping["management"]
  security_audit_account_id = module.shared.account_mapping["security-audit"]
}
