variable "name_prefix"        { type = string }
variable "vpc_id"             { type = string }
variable "public_subnet_ids"  { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "api_image"          { type = string }
variable "db_url"             { type = string; sensitive = true }
variable "redis_url"          { type = string }
variable "anthropic_api_key"  { type = string; sensitive = true }
variable "environment"        { type = string }
