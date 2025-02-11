terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source = "./modules/networking"

  vpc_cidr            = var.vpc_cidr
  aws_region          = var.aws_region
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones  = ["a", "b"]
}

module "security" {
  source = "./modules/security"

  vpc_id = module.networking.vpc_id
}

module "iam" {
  source = "./modules/iam"
}

module "ecs" {
  source = "./modules/ecs"

  subnet_ids            = module.networking.subnet_ids
  security_group_id     = module.security.security_group_id
  execution_role_arn    = module.iam.execution_role_arn
  aws_region            = var.aws_region
  ecr_image_url         = var.ecr_image_url
  vpc_id                = module.networking.vpc_id
  container_port        = var.container_port
  container_cpu         = var.container_cpu
  container_memory      = var.container_memory
  service_desired_count = var.service_desired_count
}