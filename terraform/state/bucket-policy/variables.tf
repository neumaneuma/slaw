variable "state_bucket_id" {
  description = "The ID of the S3 bucket to store Terraform state files."
  type        = string
}

variable "state_bucket_arn" {
  description = "The ARN of the S3 bucket to store Terraform state files."
  type        = string
}

variable "state_file_name" {
  description = "The name of the state file."
  type        = string
}

variable "account_id" {
  description = "The AWS account ID."
  type        = string
}
