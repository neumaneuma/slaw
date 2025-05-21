variable "region" {
  description = "AWS region"
  type        = string
}

variable "session_name" {
  description = "Session name for the role"
  type        = string
}

variable "role_arn" {
  description = "Role ARN to assume"
  type        = string
}
