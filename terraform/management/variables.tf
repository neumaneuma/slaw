variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "trail_name" {
  description = "CloudTrail name"
  type        = string
  default     = "permissions-audit-trail"
}

variable "ou_mapping" {
  description = "OUs mapping"
  type        = map(string)
  default = {
    "Security"         = "Security",
    "Infrastructure"   = "Infrastructure",
    "Workloads"        = "Workloads",
    "Exceptions"       = "Exceptions",
    "Sandbox"          = "Sandbox",
    "Onboarding"       = "Onboarding",
    "Nursery"          = "Nursery",
    "Suspended"        = "Suspended",
    "IncidentResponse" = "IncidentResponse"
  }
}

variable "security_accounts" {
  description = "Mapping of account names to emails in the Security OU"
  type        = map(string)
  default = {
    # "LogArchive": "storks-00elders+log_archive@icloud.com",
    "SecurityAudit" : "storks-00elders+security_audit@icloud.com",
    # "SecurityOperations": "storks-00elders+security_operations2@icloud.com",
    # "IAM" : "storks-00elders+iam2@icloud.com"
  }
}

variable "sso_admin_users" {
  description = "A collection of SSO users and their attributes"
  type        = map(map(string))
  default = {
    "johndoe" = {
      display_name = "John Doe"
      given_name   = "John"
      family_name  = "Doe"
      email        = "storks-00elders+ssouser1@icloud.com"
    }
  }
}
