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
    "LogArchive" : "storks-00elders+log_archive@icloud.com",
    "SecurityAudit1" : "storks-00elders+security_audit1@icloud.com",
    "SecurityOperations" : "storks-00elders+security_operations3@icloud.com",
    "IAM" : "storks-00elders+iam3@icloud.com"
  }
}

variable "workloads_ous" {
  description = "OUs in the Workloads OU"
  type        = list(string)
  default = [
    "Prod",
    "NonProd",
  ]
}

variable "nonprod_accounts" {
  description = "Mapping of account names to emails in the NonProd OU"
  type        = map(string)
  default = {
    "TestAccount1" : "storks-00elders+test_account1@icloud.com",
    "SystemDesign" : "storks-00elders+system_design@icloud.com"
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
