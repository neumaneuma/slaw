output "cloudtrail_s3_bucket_arn" {
  value = aws_s3_bucket.audit_logs.arn
}

output "cloudtrail_s3_bucket_name" {
  value = aws_s3_bucket.audit_logs.bucket
}
