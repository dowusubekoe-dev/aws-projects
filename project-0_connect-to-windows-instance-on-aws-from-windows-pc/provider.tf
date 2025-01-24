# This file is used to configure the AWS provider for Terraform.

#  It specifies the required provider and its version.
terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
   }

# AWS Provider Configuration
   provider "aws" {
     region = "${var.aws_region}"
   }