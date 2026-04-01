locals {
  name_prefix = "${var.app_name}-${var.environment}"
}

module "vpc" {
  source      = "./modules/vpc"
  name_prefix = local.name_prefix
  cidr        = var.vpc_cidr
  environment = var.environment
}

module "rds" {
  source            = "./modules/rds"
  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  db_username       = var.db_username
  db_password       = var.db_password
  environment       = var.environment
}

module "redis" {
  source      = "./modules/redis"
  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnet_ids
  environment = var.environment
}

module "ecs" {
  source            = "./modules/ecs"
  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  api_image         = var.api_image
  db_url            = "postgresql+asyncpg://${var.db_username}:${var.db_password}@${module.rds.endpoint}/cloudsentry"
  redis_url         = "redis://${module.redis.endpoint}:6379/0"
  anthropic_api_key = var.anthropic_api_key
  environment       = var.environment
}

resource "aws_ecr_repository" "api" {
  name                 = "${local.name_prefix}-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
