# Dev environment configuration - main.tf

provider "aws" {
  region = var.aws_region
}

provider "random" {}

provider "null" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }

  # Uncomment this block to use S3 as backend
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "dev/terraform.tfstate"
  #   region = "us-east-2"
  # }
}

module "lambda_api" {
  source = "../../modules/lambda_api"

  environment                = var.environment
  aws_region                 = var.aws_region
  log_retention_days         = var.log_retention_days
  lambda_timeout             = var.lambda_timeout
  lambda_memory_size         = var.lambda_memory_size
  enable_detailed_monitoring = var.enable_detailed_monitoring
  api_error_threshold        = var.api_error_threshold
  tags                       = var.tags
  alarm_actions              = var.alarm_actions
  ok_actions                 = var.ok_actions
}
