# Tests for the Redis security group rules.
#
# Verifies that port 6379 is accessible within the VPC and that the
# cluster is not reachable from the open internet.

mock_provider "aws" {}

variables {
  name_prefix = "test"
  vpc_id      = "vpc-00000000000000000"
  subnet_ids  = ["subnet-00000000000000001", "subnet-00000000000000002"]
  environment = "dev"
}

run "redis_sg_allows_port_6379_inbound" {
  command = plan

  assert {
    condition = anytrue([
      for rule in aws_security_group.redis.ingress :
      rule.from_port == 6379 && rule.to_port == 6379 && rule.protocol == "tcp"
    ])
    error_message = "Redis security group must allow inbound TCP traffic on port 6379"
  }
}

run "redis_sg_not_open_to_internet" {
  command = plan

  assert {
    condition = alltrue([
      for rule in aws_security_group.redis.ingress :
      !contains(rule.cidr_blocks, "0.0.0.0/0")
    ])
    error_message = "Redis security group must not allow inbound traffic from 0.0.0.0/0"
  }
}
