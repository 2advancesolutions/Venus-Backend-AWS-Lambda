# Terraform configuration for AWS Lambda function
# Alternative to serverless.yml for infrastructure as code

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Archive the Lambda function code
data "archive_file" "users_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/users"
  output_path = "${path.module}/../.build/users-lambda.zip"
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "venus-users-lambda-execution-role-${var.environment}"

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
}

# Attach basic execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# Lambda function
resource "aws_lambda_function" "users_function" {
  filename         = data.archive_file.users_lambda.output_path
  function_name    = "venus-get-users-${var.environment}"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "handler.lambda_handler"
  source_code_hash = data.archive_file.users_lambda.output_base64sha256
  runtime         = "python3.11"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = {
    Name        = "venus-get-users"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.users_function.function_name}"
  retention_in_days = 7
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "users_api" {
  name        = "venus-users-api-${var.environment}"
  description = "API Gateway for Users Lambda function"
}

# API Gateway Resource
resource "aws_api_gateway_resource" "users_resource" {
  rest_api_id = aws_api_gateway_rest_api.users_api.id
  parent_id   = aws_api_gateway_rest_api.users_api.root_resource_id
  path_part   = "users"
}

# API Gateway Method (GET)
resource "aws_api_gateway_method" "users_get" {
  rest_api_id   = aws_api_gateway_rest_api.users_api.id
  resource_id   = aws_api_gateway_resource.users_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway Integration
resource "aws_api_gateway_integration" "users_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.users_api.id
  resource_id             = aws_api_gateway_resource.users_resource.id
  http_method             = aws_api_gateway_method.users_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.users_function.invoke_arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.users_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.users_api.execution_arn}/*/*"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "users_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.users_api.id
  
  depends_on = [
    aws_api_gateway_integration.users_lambda_integration
  ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.users_resource.id,
      aws_api_gateway_method.users_get.id,
      aws_api_gateway_integration.users_lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "users_api_stage" {
  deployment_id = aws_api_gateway_deployment.users_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.users_api.id
  stage_name    = var.environment
}

# Outputs
output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.users_function.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.users_function.function_name
}

output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = "${aws_api_gateway_stage.users_api_stage.invoke_url}/users"
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.users_api.id
}
