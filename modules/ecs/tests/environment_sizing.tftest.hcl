# Tests for environment-conditional resource sizing in the ECS module.
#
# These are plan-only tests using a mock AWS provider, so they require no
# AWS credentials and run entirely offline.
#
# Run from the module root: terraform test

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
}

# ---------------------------------------------------------------------------
# Task definition: CPU and memory allocation
# ---------------------------------------------------------------------------

run "prod_task_gets_full_cpu_and_memory" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = aws_ecs_task_definition.api.cpu == "1024"
    error_message = "prod ECS task must request 1024 CPU units, got ${aws_ecs_task_definition.api.cpu}"
  }

  assert {
    condition     = aws_ecs_task_definition.api.memory == "2048"
    error_message = "prod ECS task must request 2048 MiB memory, got ${aws_ecs_task_definition.api.memory}"
  }
}

run "dev_task_gets_reduced_cpu_and_memory" {
  command = plan

  variables {
    environment = "dev"
  }

  assert {
    condition     = aws_ecs_task_definition.api.cpu == "512"
    error_message = "dev ECS task must request 512 CPU units, got ${aws_ecs_task_definition.api.cpu}"
  }

  assert {
    condition     = aws_ecs_task_definition.api.memory == "1024"
    error_message = "dev ECS task must request 1024 MiB memory, got ${aws_ecs_task_definition.api.memory}"
  }
}

# ---------------------------------------------------------------------------
# Service: desired replica count
# ---------------------------------------------------------------------------

run "prod_service_runs_two_replicas" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = aws_ecs_service.api.desired_count == 2
    error_message = "prod ECS service must run 2 replicas for availability, got ${aws_ecs_service.api.desired_count}"
  }
}

run "dev_service_runs_one_replica" {
  command = plan

  variables {
    environment = "dev"
  }

  assert {
    condition     = aws_ecs_service.api.desired_count == 1
    error_message = "dev ECS service must run 1 replica to reduce cost, got ${aws_ecs_service.api.desired_count}"
  }
}

# ---------------------------------------------------------------------------
# Service: network placement — tasks must land in private subnets
# ---------------------------------------------------------------------------

run "service_tasks_placed_in_private_subnets" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition = alltrue([
      for s in aws_ecs_service.api.network_configuration[0].subnets :
      contains(["subnet-00000000000000003", "subnet-00000000000000004"], s)
    ])
    error_message = "ECS service tasks must be placed in private subnets, not public ones"
  }
}
