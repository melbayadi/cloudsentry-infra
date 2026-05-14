plugin "aws" {
  enabled = true
  version = "0.34.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  call_module_type    = "local"
  disabled_by_default = false
}

# Core Terraform rules
rule "terraform_deprecated_interpolation" { enabled = true }
rule "terraform_deprecated_lookup"        { enabled = true }
rule "terraform_required_providers"       { enabled = true }
rule "terraform_required_version"         { enabled = true }
rule "terraform_unused_declarations"      { enabled = true }
rule "terraform_documented_variables"     { enabled = false }
rule "terraform_documented_outputs"       { enabled = false }
rule "terraform_naming_convention"        { enabled = false }

# AWS-specific rules — catch invalid resource configurations before apply
rule "aws_ecs_task_definition_invalid_cpu"    { enabled = true }
rule "aws_ecs_task_definition_invalid_memory" { enabled = true }
rule "aws_db_instance_invalid_engine"         { enabled = true }
rule "aws_elasticache_cluster_invalid_engine" { enabled = true }
