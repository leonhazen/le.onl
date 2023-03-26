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