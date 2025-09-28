# HTTP API Gateway
resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "${var.environment}-list-service-api"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway for ListService Lambda function"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["content-type"]
    max_age       = 300
  }

  tags = merge(
    {
      Environment = var.environment,
      Service     = "list-service",
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# Default stage for the API Gateway with detailed logging
resource "aws_apigatewayv2_stage" "lambda_stage" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true

  # Access logging configuration with only supported variables
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      routeKey       = "$context.routeKey"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
      path           = "$context.path"
    })
  }

  # Set up detailed metrics if enabled
  default_route_settings {
    throttling_burst_limit   = 100
    throttling_rate_limit    = 50
    detailed_metrics_enabled = var.enable_detailed_monitoring
  }

  tags = merge(
    {
      Environment = var.environment,
      Service     = "list-service",
      ManagedBy   = "terraform"
    },
    var.tags
  )

  # Ensure log group exists before the stage
  depends_on = [aws_cloudwatch_log_group.api_gateway_logs]
}

# Lambda integration with API Gateway
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.lambda_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.list_service.invoke_arn
  payload_format_version = "2.0"
  integration_method     = "POST"

  # Enable logging to see request/response in CloudWatch
  timeout_milliseconds = 30000 # 30 seconds
}

# Route for the root path
resource "aws_apigatewayv2_route" "root_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Route for list operations
resource "aws_apigatewayv2_route" "list_routes" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "ANY /list/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}