terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  backend "s3" {
    bucket         = "cloudsentry-terraform-state"
    key            = "infra/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "cloudsentry-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "CloudSentry"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
