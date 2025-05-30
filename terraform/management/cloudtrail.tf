data "terraform_remote_state" "log_archive" {
  backend = "s3"

  config = {
    bucket = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key    = "state/log-archive.tfstate"
    region = "us-east-1"
  }
}

resource "aws_cloudtrail" "audit" {
  name                          = var.trail_name
  s3_bucket_name                = data.terraform_remote_state.log_archive.outputs.s3_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true
}

resource "aws_accessanalyzer_analyzer" "main" {
  analyzer_name = "permissions-analyzer"
  type          = "ACCOUNT"
}
