# Development environment variables

environment        = "dev"
aws_region         = "us-east-2"
log_retention_days = 7

# Lambda configuration
lambda_timeout     = 30
lambda_memory_size = 256

# CloudWatch configuration
enable_detailed_monitoring = true
api_error_threshold        = 5

# CloudWatch alarm actions
# Example: How to add SNS topic ARN for alerting
# alarm_actions         = ["arn:aws:sns:us-east-2:123456789012:dev-alerts"]
# ok_actions            = ["arn:aws:sns:us-east-2:123456789012:dev-alerts"]
alarm_actions = []
ok_actions    = []

# Additional tags
tags = {
  Owner      = "DevTeam"
  Project    = "ListService"
  CostCenter = "Development"
}