output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail"
  value       = aws_cloudtrail.audit.arn
}
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.org.id
}

output "current_aws_arn" {
  value = data.aws_caller_identity.current.arn
}
