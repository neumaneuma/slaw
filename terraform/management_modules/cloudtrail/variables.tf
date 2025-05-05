variable "region" {
  description = "AWS region"
  type        = string
}

variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "new_bucket_name" {
  description = "Name of the new S3 bucket"
  type        = string
}
