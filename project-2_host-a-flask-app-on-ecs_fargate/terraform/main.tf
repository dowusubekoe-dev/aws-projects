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