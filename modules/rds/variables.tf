variable "name_prefix"  { type = string }
variable "vpc_id"       { type = string }
variable "subnet_ids"   { type = list(string) }
variable "db_username"  { type = string; sensitive = true }
variable "db_password"  { type = string; sensitive = true }
variable "environment"  { type = string }
