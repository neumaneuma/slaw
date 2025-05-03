output "security_audit_account_id" {
  description = "The ID of the SecurityAudit account"
  value       = module.organizations.security_audit_account_id
}

output "cloudtrail_bucket_name" {
  description = "The name of the S3 bucket for CloudTrail logs"
  value       = module.cloudtrail.cloudtrail_s3_bucket_name
}
