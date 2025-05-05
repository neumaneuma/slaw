output "cloudtrail_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs"
  value       = module.cloudtrail.cloudtrail_s3_bucket_name
}

output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = module.cloudtrail.cloudtrail_arn
}

output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = module.organizations.organization_id
}
