terraform {
  # https://developer.hashicorp.com/terraform/language/expressions/version-constraints
  # use version = ">= a.b.c" when want to upgrade, manually copy the latest version here (pretty mid, maybe
  # can write a script to do this), then run terraform init -upgrade
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
  required_version = "~> 1.5"
}
