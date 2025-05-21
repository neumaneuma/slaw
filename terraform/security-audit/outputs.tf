output "us_west_2_guardduty_detector_id" {
  value = module.guardduty-us-west-2.guardduty_detector_id
}

output "us_east_1_guardduty_detector_id" {
  value = module.guardduty-us-east-1.guardduty_detector_id
}

output "guardduty_us_west_2_region" {
  value = module.guardduty-us-west-2.provider_region
}

output "guardduty_us_east_1_region" {
  value = module.guardduty-us-east-1.provider_region
}

output "current_aws_arn" {
  value = data.aws_caller_identity.current.arn
}
