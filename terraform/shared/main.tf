variable "account_mapping" {
  description = "Mapping of account IDs to account names"
  type        = map(string)
  default = {
    "management"     = 992382570951
    "security-audit" = 222785560885
  }
}

output "account_mapping" {
  value = var.account_mapping
}
