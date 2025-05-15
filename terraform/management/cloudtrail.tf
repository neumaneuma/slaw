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
