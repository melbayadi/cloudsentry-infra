variable "name_prefix"        { type = string }
variable "vpc_id"             { type = string }
variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "redis_url"          { type = string }

variable "api_image" {
  type = string
  validation {
    condition     = length(var.api_image) > 0
    error_message = "api_image must not be empty — provide a fully-qualified image URI."
  }
}

variable "db_url" {
  type      = string
  sensitive = true
}

variable "anthropic_api_key" {
  type      = string
  sensitive = true
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be 'dev' or 'prod'."
  }
}
