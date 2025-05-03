terraform {
  backend "s3" {
    bucket       = "main-state-ba1551d4-7af8-1aab-93d3-0499ce761296"
    key          = "state/security-audit.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

resource "random_uuid" "uuid" {}

resource "aws_s3_bucket" "bucket" {
  bucket = "cloudtrail-audit-logs-${random_uuid.uuid.result}"
}
