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

data "aws_caller_identity" "current" {}

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
