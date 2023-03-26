variable "region" {
  type        = string
  description = "AWS Region"
  default     = "ap-southeast-2"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "le.onl"
}

variable "domain" {
  type        = string
  description = "Domain name"
  default     = "le.onl"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
  sensitive   = true
}