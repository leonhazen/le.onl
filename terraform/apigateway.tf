resource "aws_api_gateway_rest_api" "api" {
  name = "lambda-api"
}


resource "aws_api_gateway_method" "get_source_ip_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_source_ip_integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.get_source_ip_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda["get_source_ip"].invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.get_source_ip_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.environment
}
