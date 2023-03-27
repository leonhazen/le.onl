resource "aws_api_gateway_domain_name" "api" {
  domain_name              = var.hostname
  regional_certificate_arn = aws_acm_certificate_validation.api.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_acm_certificate" "api" {
  domain_name       = var.hostname
  validation_method = "DNS"
}


resource "aws_acm_certificate_validation" "api" {
  certificate_arn = aws_acm_certificate.api.arn
}

resource "aws_api_gateway_base_path_mapping" "api" {
  domain_name = aws_api_gateway_domain_name.api.domain_name
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = var.environment
}

# Create CNAME record in cloudflare
data "cloudflare_zones" "zones" {
  filter {
    name = var.domain
  }
}

resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zones.zones.zones[0].id
  name    = var.hostname
  value   = aws_api_gateway_domain_name.api.regional_domain_name
  type    = "CNAME"
  ttl     = 300
  proxied = false
}

resource "cloudflare_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id = data.cloudflare_zones.zones.zones[0].id
  name    = each.value.name
  value   = each.value.record
  type    = each.value.type
  ttl     = 60
  proxied = false
}
