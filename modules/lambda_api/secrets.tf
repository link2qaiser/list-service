# Add a random suffix to secret name to avoid conflicts with deleted secrets
resource "random_id" "secret_suffix" {
  byte_length = 8
}

# Secret for API configuration
resource "aws_secretsmanager_secret" "api_config" {
  name        = "${var.environment}-list-service-api-config-${random_id.secret_suffix.hex}"
  description = "Configuration for ListService API"

  tags = merge(
    {
      Environment = var.environment,
      Service     = "list-service",
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# Initial secret version with example values
resource "aws_secretsmanager_secret_version" "api_config_initial" {
  secret_id = aws_secretsmanager_secret.api_config.id
  secret_string = jsonencode({
    API_KEY     = "example-api-key-${var.environment}"
    API_VERSION = "0.1.0"
    # Add other configuration as needed
  })
}

# IAM policy to allow Lambda to access the secret
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.environment}-list-service-secrets-policy"
  description = "Policy to allow Lambda to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.api_config.arn
      }
    ]
  })
}

# Attach secrets access policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_secrets" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}