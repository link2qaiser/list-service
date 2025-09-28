# Lambda API Module - variables.tf

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-2"
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 14
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# CloudWatch alarm variables
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

variable "api_error_threshold" {
  description = "Threshold for API Gateway 4XX error alarm"
  type        = number
  default     = 5
}

variable "enable_detailed_monitoring" {
  description = "Whether to enable detailed CloudWatch monitoring"
  type        = bool
  default     = false
}
