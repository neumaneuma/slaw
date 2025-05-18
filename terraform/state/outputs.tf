output "main_state_bucket_name" {
  value = aws_s3_bucket.main_state.id
}

output "current_aws_arn" {
  value = data.aws_caller_identity.current.arn
}
