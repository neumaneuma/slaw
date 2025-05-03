output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.org.id
}

output "organization_arn" {
  description = "The ARN of the AWS Organization"
  value       = aws_organizations_organization.org.arn
}

output "organization_master_account_id" {
  description = "The ID of the master account"
  value       = aws_organizations_organization.org.master_account_id
}

output "organization_master_account_arn" {
  description = "The ARN of the master account"
  value       = aws_organizations_organization.org.master_account_arn
}

output "security_audit_account_id" {
  description = "The ID of the SecurityAudit account"
  value       = aws_organizations_account.security_audit.id
}
