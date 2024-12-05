terraform {
  required_version = "1.9.5"
  required_providers {
    aws = {
      region = "var.aws_region"
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }
}