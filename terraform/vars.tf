variable "region" {
  type        = string
  description = "AWS Region"
  default     = "ap-southeast-2"
}

variable "domain" {
  type        = string
  description = "Domain zone"
  default     = "le.onl"
}

variable "hostname" {
  type        = string
  description = "Hostname"
  default     = "api.le.onl"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
  sensitive   = true
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}
