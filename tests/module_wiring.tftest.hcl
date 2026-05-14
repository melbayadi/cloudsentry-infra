# Integration tests that verify the root module plan succeeds and that
# key high-level properties hold across the wired modules.
#
# Subnet-tier correctness (private vs public) for ECS, RDS, and Redis
# is verified at the module level:
#   - modules/ecs/tests/environment_sizing.tftest.hcl: service_tasks_placed_in_private_subnets
#   - modules/ecs/tests/network_security.tftest.hcl:   alb_placed_in_public_subnets
#
# Root-level plan tests focus on properties that cross module boundaries
# and can be evaluated without AWS API calls.

mock_provider "aws" {}

override_data {
  target = module.vpc.data.aws_availability_zones.available
  values = {
    names = ["us-west-2a", "us-west-2b"]
  }
}

variables {
  environment       = "prod"
  api_image         = "nginx:latest"
  db_password       = "test-password-123"
  anthropic_api_key = "test-key"
}

# ---------------------------------------------------------------------------
# ECR — root-level resource
# ---------------------------------------------------------------------------

run "ecr_has_scan_on_push" {
  command = plan

  assert {
    condition     = aws_ecr_repository.api.image_scanning_configuration[0].scan_on_push == true
    error_message = "ECR repository must scan images on push to catch known vulnerabilities"
  }
}

# ---------------------------------------------------------------------------
# ALB — internet-facing so it can serve external traffic
# ---------------------------------------------------------------------------

run "alb_is_internet_facing" {
  command = plan

  assert {
    condition     = module.ecs.alb_internal == false
    error_message = "ALB must be internet-facing so it can receive external traffic"
  }
}

# ---------------------------------------------------------------------------
# Dev environment — verify the plan succeeds with a different environment
# to confirm conditional logic is valid for both branches.
# ---------------------------------------------------------------------------

run "dev_environment_plan_succeeds" {
  command = plan

  variables {
    environment = "dev"
  }

  assert {
    condition     = aws_ecr_repository.api.image_scanning_configuration[0].scan_on_push == true
    error_message = "ECR must have scan-on-push enabled in all environments"
  }
}
