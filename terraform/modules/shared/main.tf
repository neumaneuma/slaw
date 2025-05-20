variable "account_mapping" {
  description = "Mapping of account IDs to account names"
  type        = map(string)
  default = {
    "management"          = 992382570951
    "security-audit"      = 697482068871
    "iam"                 = 471887341343
    "log-archive"         = 222785560885
    "security-operations" = 383313559638
    "test-account1"       = 334935312185
    "system-design"       = 193672753492
  }
}

output "account_mapping" {
  value = var.account_mapping
}

variable "sso_user_ids" {
  description = "A collection of SSO user IDs"
  type        = map(string)
  default = {
    "johndoe" = "e4584428-5021-7063-ebfd-4814159e7ae0"
  }
}

output "sso_user_ids" {
  value = var.sso_user_ids
}
