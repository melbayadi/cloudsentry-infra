# CloudSentry Infrastructure

Terraform infrastructure for CloudSentry — ECS Fargate, RDS PostgreSQL, ElastiCache Redis, VPC, and ALB on AWS.

## Architecture

```
                    ┌──────────────────────────────────────┐
                    │              AWS VPC                  │
  Internet ──► ALB ─┤  Public Subnets                      │
                    │  Private Subnets                      │
                    │    ├── ECS Fargate (API)              │
                    │    ├── RDS PostgreSQL 16              │
                    │    └── ElastiCache Redis 7            │
                    └──────────────────────────────────────┘
```

## Modules
| Module | Description |
|--------|-------------|
| `modules/vpc` | VPC, subnets, IGW, NAT Gateway, route tables |
| `modules/ecs` | ECS Cluster, Fargate service, ALB, IAM roles |
| `modules/rds` | RDS PostgreSQL, subnet group, security group |
| `modules/redis` | ElastiCache Redis, subnet group |

## Usage

```bash
cp example.tfvars terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## State Backend
Remote state stored in S3 + DynamoDB locking.
Bucket: `cloudsentry-terraform-state`
Table: `cloudsentry-tf-lock`
