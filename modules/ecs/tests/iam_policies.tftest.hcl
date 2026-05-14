# Tests for IAM trust policies and inline task policy in the ECS module.
#
# Validates that roles are tightly scoped to ecs-tasks.amazonaws.com and
# that the task policy grants only the specific actions the application
# needs — no wildcards, no IAM/admin permissions.

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
# Trust policies — who can assume each role
# ---------------------------------------------------------------------------

run "execution_role_trust_scoped_to_ecs_tasks" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role.ecs_execution.assume_role_policy).Statement[0].Principal.Service == "ecs-tasks.amazonaws.com"
    error_message = "ECS execution role must only be assumable by ecs-tasks.amazonaws.com"
  }
}

run "task_role_trust_scoped_to_ecs_tasks" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role.ecs_task.assume_role_policy).Statement[0].Principal.Service == "ecs-tasks.amazonaws.com"
    error_message = "ECS task role must only be assumable by ecs-tasks.amazonaws.com"
  }
}

# ---------------------------------------------------------------------------
# Execution role — must use the AWS-managed policy, nothing broader
# ---------------------------------------------------------------------------

run "execution_role_uses_aws_managed_policy_only" {
  command = plan

  assert {
    condition     = aws_iam_role_policy_attachment.ecs_execution.policy_arn == "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    error_message = "ECS execution role must attach AmazonECSTaskExecutionRolePolicy and nothing wider"
  }
}

# ---------------------------------------------------------------------------
# Task policy — no wildcard actions, no IAM/admin permissions
# ---------------------------------------------------------------------------

run "task_policy_has_no_wildcard_action" {
  command = plan

  assert {
    condition = !anytrue(flatten([
      for stmt in jsondecode(aws_iam_role_policy.ecs_task_policy.policy).Statement : [
        for action in tolist(stmt.Action) : action == "*"
      ]
    ]))
    error_message = "ECS task IAM policy must not grant wildcard Action ('*') — use explicit action names"
  }
}

run "task_policy_grants_no_iam_or_admin_permissions" {
  command = plan

  assert {
    condition = !anytrue(flatten([
      for stmt in jsondecode(aws_iam_role_policy.ecs_task_policy.policy).Statement : [
        for action in tolist(stmt.Action) :
        startswith(action, "iam:") || startswith(action, "organizations:") || startswith(action, "sts:AssumeRole")
      ]
    ]))
    error_message = "ECS task IAM policy must not grant IAM, Organizations, or role-assumption permissions"
  }
}
