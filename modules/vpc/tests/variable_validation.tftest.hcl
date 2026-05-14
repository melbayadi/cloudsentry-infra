# Tests that the VPC module variable validation rules reject invalid inputs.
#
# The aws_availability_zones data source is overridden so tests run
# without AWS credentials.

mock_provider "aws" {}

override_data {
  target = data.aws_availability_zones.available
  values = {
    names = ["us-west-2a", "us-west-2b"]
  }
}

variables {
  name_prefix = "test"
  environment = "dev"
  cidr        = "10.0.0.0/16"
}

run "reject_non_cidr_string" {
  command = plan

  variables {
    cidr = "not-a-cidr"
  }

  expect_failures = [var.cidr]
}

run "reject_plain_ip_without_prefix_length" {
  command = plan

  variables {
    cidr = "10.0.0.0"
  }

  expect_failures = [var.cidr]
}

run "accept_valid_cidr_and_creates_correct_vpc" {
  command = plan

  variables {
    cidr = "192.168.0.0/24"
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "192.168.0.0/24"
    error_message = "VPC must use the CIDR block provided by the caller"
  }
}
