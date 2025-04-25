# terraform-apache-ec2/variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources in. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "instance_type" {
  description = "The EC2 instance type. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "key_name" {
  description = "Name of the EC2 Key Pair to use for SSH access. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "project_name" {
  description = "A name prefix for resources."
  type        = string
  default     = "ecommerce-web" # Keeping this default is often okay, but can be moved too if desired
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed for SSH access (e.g., ['YOUR_IP/32']). Set in terraform.tfvars."
  type        = list(string)
  # No default - value provided via tfvars
}

# --- Networking Variables ---

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "public_subnet_a_cidr_block" {
  description = "CIDR block for the public subnet in AZ A. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "public_subnet_b_cidr_block" {
  description = "CIDR block for the public subnet in AZ B. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}