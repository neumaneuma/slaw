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


resource "aws_guardduty_detector" "detector" {
  enable = true
}

resource "aws_guardduty_organization_configuration" "config" {
  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.detector.id
}
