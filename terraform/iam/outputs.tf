output "current_aws_arn" {
  value = data.aws_caller_identity.current.arn
}
