# Tests that the ECS module variable validation rules reject invalid inputs.
#
# Uses expect_failures to confirm Terraform surfaces a meaningful error
# rather than silently accepting bad values.

mock_provider "aws" {}

variables {
  name_prefix        = "test"
  vpc_id             = "vpc-00000000000000000"
  public_subnet_ids  = ["subnet-00000000000000001", "subnet-00000000000000002"]
  private_subnet_ids = ["subnet-00000000000000003", "subnet-00000000000000004"]
  db_url             = "postgresql://user:pass@localhost/cloudsentry"
  redis_url          = "redis://localhost:6379"
  anthropic_api_key  = "test-key"
  environment        = "dev"
  api_image          = "nginx:latest"
}

run "reject_unknown_environment_value" {
  command = plan

  variables {
    environment = "staging"
  }

  expect_failures = [var.environment]
}

run "reject_empty_api_image" {
  command = plan

  variables {
    api_image = ""
  }

  expect_failures = [var.api_image]
}
