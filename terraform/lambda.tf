locals {
  lambda_configurations = {
    get_source_ip = {
      filename = "get_source_ip.zip"
      handler  = "main.lambda_handler"
      path     = "ip"
      method   = "GET"
    }
  }
}


resource "aws_lambda_function" "lambda" {
  for_each = local.lambda_configurations

  function_name = each.key
  handler       = each.value.handler
  runtime       = "python3.9"

  filename         = "${path.module}/../dist/${each.value.filename}"
  source_code_hash = filebase64sha256("${path.module}/../dist/${each.value.filename}")

  role = aws_iam_role.lambda_execution_role.arn

  environment {
    variables = {
      APP_ENV = var.environment
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_logs
  ]
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

# Create log group for each lambda function
resource "aws_cloudwatch_log_group" "lambda" {
  for_each = local.lambda_configurations

  name              = "/aws/lambda/${each.key}"
  retention_in_days = 7
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}