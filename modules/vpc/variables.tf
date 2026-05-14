variable "name_prefix" { type = string }
variable "environment"  { type = string }

variable "cidr" {
  type = string
  validation {
    condition     = can(cidrhost(var.cidr, 0))
    error_message = "cidr must be a valid IPv4 CIDR block (e.g. 10.0.0.0/16)."
  }
}
