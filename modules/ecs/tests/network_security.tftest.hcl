# Tests for security group rules and load balancer network placement
# in the ECS module.
#
# Verifies that the ALB accepts HTTPS, the API service is not directly
# reachable from the internet, and the load balancer is placed in the
# correct (public) subnet tier.

mock_provider "aws" {}

variables {
  name_prefix        = "test"
  vpc_id             = "vpc-00000000000000000"
  public_subnet_ids  = ["subnet-00000000000000001", "subnet-00000000000000002"]
  private_subnet_ids = ["subnet-00000000000000003", "subnet-00000000000000004"]
  api_image          = "nginx:latest"
  db_url             = "postgresql://user:pass@localhost/cloudsentry"
  redis_url          = "redis://localhost:6379"
  anthropic_api_key  = "test-key"
  environment        = "prod"
}

# ---------------------------------------------------------------------------
# ALB security group
# ---------------------------------------------------------------------------

run "alb_sg_accepts_https" {
  command = plan

  assert {
    condition = anytrue([
      for rule in aws_security_group.alb.ingress :
      rule.from_port == 443 && rule.to_port == 443 && rule.protocol == "tcp"
    ])
    error_message = "ALB security group must accept HTTPS traffic on port 443"
  }
}

run "alb_sg_accepts_http" {
  command = plan

  assert {
    condition = anytrue([
      for rule in aws_security_group.alb.ingress :
      rule.from_port == 80 && rule.to_port == 80 && rule.protocol == "tcp"
    ])
    error_message = "ALB security group must accept HTTP traffic on port 80"
  }
}

# ---------------------------------------------------------------------------
# API security group — must not be directly reachable from the internet
# ---------------------------------------------------------------------------

run "api_sg_ingress_only_from_alb_not_open_cidr" {
  command = plan

  assert {
    condition = alltrue([
      for rule in aws_security_group.api.ingress :
      try(length(rule.cidr_blocks), 0) == 0 &&
      try(length(rule.ipv6_cidr_blocks), 0) == 0
    ])
    error_message = "API security group must only accept traffic from the ALB security group, not from open CIDR ranges"
  }
}

# ---------------------------------------------------------------------------
# ALB placement — must use the public subnet tier
# ---------------------------------------------------------------------------

run "alb_placed_in_public_subnets" {
  command = plan

  assert {
    condition = alltrue([
      for s in tolist(aws_lb.main.subnets) :
      contains(["subnet-00000000000000001", "subnet-00000000000000002"], s)
    ])
    error_message = "ALB must be placed in public subnets so it is reachable from the internet"
  }
}

run "alb_is_internet_facing" {
  command = plan

  assert {
    condition     = aws_lb.main.internal == false
    error_message = "ALB must be internet-facing (internal = false)"
  }
}
