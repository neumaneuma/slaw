terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

# https://slaw.securosis.com/p/timmys-first-cloudformation
resource "aws_cloudformation_stack" "stack" {
  name     = "timmys-first-cloudformation"
  provider = aws

  template_body = <<TEMPLATE
AWSTemplateFormatVersion: '2010-09-09'
Description: Template to create a SNS topic named SecurityAlerts
Resources:
  SecurityAlertsTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: SecurityAlerts
TEMPLATE
}
