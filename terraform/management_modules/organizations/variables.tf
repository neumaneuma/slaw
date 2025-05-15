variable "ou_mapping" {
  description = "List of OUs"
  type        = map(string)
}

variable "security_accounts" {
  description = "Mapping of account names to emails in the Security OU"
  type        = map(string)
}
