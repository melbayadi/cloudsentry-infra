module "cloudsentry" {
  source      = "../../"
  environment = "dev"
  aws_region  = "us-west-2"
  vpc_cidr    = "10.0.0.0/16"
  api_image   = var.api_image
  db_username = var.db_username
  db_password = var.db_password
  anthropic_api_key = var.anthropic_api_key
}

variable "api_image"         { type = string }
variable "db_username"       { type = string; sensitive = true }
variable "db_password"       { type = string; sensitive = true }
variable "anthropic_api_key" { type = string; sensitive = true }
