resource "aws_api_gateway_rest_api" "api" {
  name = "lambda-api"
}

resource "aws_api_gateway_resource" "resource" {
  for_each = local.lambda_configurations

  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.value.path
}

resource "aws_api_gateway_method" "method" {
  for_each = local.lambda_configurations

  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource[each.key].id
  http_method   = each.value.method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  for_each = local.lambda_configurations

  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource[each.key].id
  http_method = aws_api_gateway_method.method[each.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda[each.key].invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.integration
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.environment
}
