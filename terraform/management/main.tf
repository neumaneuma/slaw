terraform {
  backend "s3" {
    bucket       = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key          = "state/aws.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  # default provider
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"

}

data "aws_caller_identity" "current" {}

module "shared" {
  source = "../modules/shared"
}

module "cloudformation" {
  source = "../modules/cloudformation"
  region = "us-east-1"
}

module "cloudformation2" {
  source = "../modules/cloudformation"
  region = "us-west-2"
}
