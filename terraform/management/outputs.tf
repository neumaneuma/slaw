output "cloudtrail_arn" {
  description = "The ARN of the CloudTrail"
  value       = aws_cloudtrail.audit.arn
}

output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.org.id
}

output "root_ou_id" {
  description = "The ID of the AWS Organization root OU"
  value       = aws_organizations_organization.org.roots[0].id
}

output "current_aws_arn" {
  value = data.aws_caller_identity.current.arn
}

# output "johndoe" {
#   description = "The ARN of the johndoe user"
#   value       = aws_identitystore_user.sso_user["johndoe"].user_id
# }
