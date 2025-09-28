output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_api.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_api.function_arn
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.lambda_api.api_gateway_endpoint
}

output "list_endpoint" {
  description = "URL for the /list endpoint"
  value       = module.lambda_api.api_list_endpoint
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group name"
  value       = module.lambda_api.cloudwatch_log_group
}

output "dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${var.environment}-list-service-api-dashboard"
}

output "secrets_manager_name" {
  description = "Name of the Secrets Manager secret"
  value       = module.lambda_api.secrets_manager_name
}