# Tests for environment-conditional configuration in the RDS module.
#
# These are plan-only tests using a mock AWS provider, so they require no
# AWS credentials and run entirely offline.
#
# Run from the module root: terraform test

mock_provider "aws" {}

variables {
  name_prefix = "test"
  vpc_id      = "vpc-00000000000000000"
  subnet_ids  = ["subnet-00000000000000001", "subnet-00000000000000002"]
  db_username = "admin"
  db_password = "test-password-1234"
}

# ---------------------------------------------------------------------------
# Instance sizing
# ---------------------------------------------------------------------------

run "prod_uses_medium_instance" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = aws_db_instance.main.instance_class == "db.t3.medium"
    error_message = "prod RDS must use db.t3.medium for adequate performance, got ${aws_db_instance.main.instance_class}"
  }
}

run "dev_uses_micro_instance" {
  command = plan

  variables {
    environment = "dev"
  }

  assert {
    condition     = aws_db_instance.main.instance_class == "db.t3.micro"
    error_message = "dev RDS must use db.t3.micro to reduce cost, got ${aws_db_instance.main.instance_class}"
  }
}

# ---------------------------------------------------------------------------
# Data protection: deletion_protection and final snapshot
# ---------------------------------------------------------------------------

run "prod_has_deletion_protection_and_final_snapshot" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = aws_db_instance.main.deletion_protection == true
    error_message = "prod RDS must have deletion_protection=true to prevent accidental data loss"
  }

  assert {
    condition     = aws_db_instance.main.skip_final_snapshot == false
    error_message = "prod RDS must not skip the final snapshot so data can be recovered after deletion"
  }
}

run "dev_allows_easy_teardown" {
  command = plan

  variables {
    environment = "dev"
  }

  assert {
    condition     = aws_db_instance.main.deletion_protection == false
    error_message = "dev RDS must have deletion_protection=false to allow easy teardown"
  }

  assert {
    condition     = aws_db_instance.main.skip_final_snapshot == true
    error_message = "dev RDS must skip the final snapshot to allow clean destroy without manual intervention"
  }
}

# ---------------------------------------------------------------------------
# Backup retention
# ---------------------------------------------------------------------------

run "prod_retains_backups_seven_days" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = aws_db_instance.main.backup_retention_period == 7
    error_message = "prod RDS must retain automated backups for 7 days, got ${aws_db_instance.main.backup_retention_period}"
  }
}

run "dev_retains_backups_one_day" {
  command = plan

  variables {
    environment = "dev"
  }

  assert {
    condition     = aws_db_instance.main.backup_retention_period == 1
    error_message = "dev RDS must retain automated backups for 1 day, got ${aws_db_instance.main.backup_retention_period}"
  }
}

# ---------------------------------------------------------------------------
# Encryption at rest (must be true in all environments)
# ---------------------------------------------------------------------------

run "storage_always_encrypted" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = aws_db_instance.main.storage_encrypted == true
    error_message = "RDS storage must always be encrypted regardless of environment"
  }
}
