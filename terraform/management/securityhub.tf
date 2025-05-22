resource "aws_securityhub_account" "default" {
  enable_default_standards = false
  auto_enable_controls     = true
}
