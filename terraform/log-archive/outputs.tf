output "s3_bucket_name" {
  value = aws_s3_bucket.bucket.id
}

output "current_aws_arn" {
  value = data.aws_caller_identity.current.arn
}
