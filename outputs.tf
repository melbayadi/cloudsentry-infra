output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "api_url" {
  description = "CloudSentry API URL"
  value       = module.ecs.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.endpoint
  sensitive   = true
}

output "ecr_repo_url" {
  description = "ECR repository URL for API image"
  value       = aws_ecr_repository.api.repository_url
}
