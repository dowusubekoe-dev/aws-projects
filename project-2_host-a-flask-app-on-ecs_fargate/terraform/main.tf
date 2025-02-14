# terraform/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Or your desired version
    }
  }
}

provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# Module for VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

# Module for ECS Cluster
module "ecs" {
  source     = "./modules/ecs"
  name       = "my_ecs_cluster"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets_ids # Use private subnets for ECS Fargate
}

# Module for Fargate Service
module "fargate" {
  source                 = "./modules/fargate"
  cluster_name           = module.ecs.cluster_name
  task_definition_name   = "host-flask-app-on-ecs-fargate"
  container_name         = "flask-app-on-ecs-fargate"
  container_image        = "dbekoe1/flask-app-on-ecs-fargate:latest" # Replace!  Push the image to Docker Hub
  container_port         = 8080
  subnet_ids             = module.vpc.private_subnets_ids
  security_group_ids     = module.vpc.security_group_ids # Use SG from the ECS module
  task_definition_cpu    = 256
  task_definition_memory = 512
}

# Module for Prometheus
module "prometheus" {
  source             = "./modules/prometheus"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets_ids
  security_group_ids = module.vpc.security_group_ids # Use SG from ECS module
}

module "monitoring" {
  source = "./modules/monitoring"

  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name
  alert_email  = var.alert_email
}