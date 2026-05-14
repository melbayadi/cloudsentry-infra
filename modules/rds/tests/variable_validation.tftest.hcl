# Tests that the RDS module variable validation rules reject invalid inputs.

mock_provider "aws" {}

variables {
  name_prefix = "test"
  vpc_id      = "vpc-00000000000000000"
  subnet_ids  = ["subnet-00000000000000001", "subnet-00000000000000002"]
  db_username = "admin"
  environment = "dev"
  db_password = "valid-password-123"
}

run "reject_short_db_password" {
  command = plan

  variables {
    db_password = "short"
  }

  expect_failures = [var.db_password]
}

run "accept_password_of_exactly_eight_chars" {
  command = plan

  variables {
    db_password = "exactly8"
  }

  assert {
    condition     = aws_db_instance.main.username == "admin"
    error_message = "RDS instance should be created when password meets minimum length"
  }
}
