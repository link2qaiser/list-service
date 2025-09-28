# Lambda API Module - main.tf

# Create layer zip for dependencies
resource "null_resource" "layer_dependencies" {
  triggers = {
    dependencies_versions = filemd5("${path.root}/../../app/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${path.module}/layer/python
      pip install -r ${path.root}/../../app/requirements.txt -t ${path.module}/layer/python
    EOT
  }
}

data "archive_file" "layer_zip" {
  depends_on  = [null_resource.layer_dependencies]
  type        = "zip"
  source_dir  = "${path.module}/layer"
  output_path = "${path.module}/lambda_layer.zip"
  excludes = [
    "env",
    "venv", 
    ".env",
    ".venv",
    "__pycache__",
    "*.pyc",
    ".pytest_cache",
    "tests/__pycache__"
  ]
}

resource "aws_lambda_layer_version" "dependencies" {
  filename   = data.archive_file.layer_zip.output_path
  layer_name = "${var.environment}-list-service-dependencies"

  compatible_runtimes = ["python3.9"]
  source_code_hash    = data.archive_file.layer_zip.output_base64sha256
}

# Create zip file for Lambda function code (without dependencies and virtual environments)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../../app"
  output_path = "${path.module}/lambda_function.zip"
  
  excludes = [
    "env",
    "venv", 
    ".env",
    ".venv",
    "__pycache__",
    "*.pyc",
    ".pytest_cache",
    "tests/__pycache__",
    "env/**",
    "venv/**",
    ".env/**",
    ".venv/**"
  ]
}

# Define the Lambda function
resource "aws_lambda_function" "list_service" {
  function_name = "${var.environment}-list-service"
  filename      = data.archive_file.lambda_zip.output_path
  handler       = "main.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Add the layer with dependencies
  layers = [aws_lambda_layer_version.dependencies.arn]

  environment {
    variables = {
      ENVIRONMENT = var.environment
      LOG_LEVEL   = var.environment == "prod" ? "INFO" : "DEBUG"
    }
  }

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size
  publish     = true # Create versioned deployment

  # Enable active tracing with X-Ray
  tracing_config {
    mode = "Active"
  }

  tags = merge(
    {
      Environment = var.environment,
      Service     = "list-service",
      ManagedBy   = "terraform"
    },
    var.tags
  )

  # Ensure CloudWatch log group exists before the Lambda function
  depends_on = [aws_cloudwatch_log_group.list_service_logs]
}

# IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-list-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Environment = var.environment,
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# CloudWatch logging permissions
resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.environment}-list-service-logging-policy"
  description = "IAM policy for Lambda logging to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# X-Ray tracing permissions
resource "aws_iam_policy" "lambda_xray" {
  name        = "${var.environment}-list-service-xray-policy"
  description = "IAM policy for Lambda X-Ray tracing"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the logging policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Attach the X-Ray policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_xray" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_xray.arn
}

# Lambda basic execution role policy attachment
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "list_service_logs" {
  name              = "/aws/lambda/${var.environment}-list-service"
  retention_in_days = var.log_retention_days

  tags = merge(
    {
      Environment = var.environment,
      Service     = "list-service",
      ManagedBy   = "terraform"
    },
    var.tags
  )
}