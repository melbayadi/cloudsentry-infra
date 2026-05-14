output "endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = true
}

output "db_subnet_ids" { value = aws_db_subnet_group.main.subnet_ids }
