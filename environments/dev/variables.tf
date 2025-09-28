# Dev environment configuration - variables.tf

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
}

variable "enable_detailed_monitoring" {
  description = "Whether to enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "api_error_threshold" {
  description = "Threshold for API Gateway 4XX error alarm"
  type        = number
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "alarm_actions" {
  description = "List of ARNs to be used as actions for the CloudWatch alarms"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to be used as OK actions for the CloudWatch alarms"
  type        = list(string)
  default     = []
}
