variable "account_mapping" {
  description = "Mapping of account IDs to account names"
  type        = map(string)
  default = {
    "management"          = 992382570951
    "security-audit"      = 697482068871
    "iam"                 = 471887341343
    "log-archive"         = 222785560885
    "security-operations" = 383313559638
  }
}

output "account_mapping" {
  value = var.account_mapping
}
