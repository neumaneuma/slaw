terraform {
  backend "s3" {
    bucket       = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key          = "state/security-audit.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

module "shared" {
  source = "../modules/shared"
}

module "guardduty-us-east-1" {
  source = "../modules/guardduty"
  region = "us-east-1"
}

module "guardduty-us-west-2" {
  source = "../modules/guardduty"
  region = "us-west-2"
}
