output "alb_dns_name"       { value = aws_lb.main.dns_name }
output "cluster_name"       { value = aws_ecs_cluster.main.name }
output "service_name"       { value = aws_ecs_service.api.name }
output "alb_internal"       { value = aws_lb.main.internal }
output "service_subnet_ids" { value = aws_ecs_service.api.network_configuration[0].subnets }
