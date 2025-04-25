# terraform-apache-ec2/variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" # Choose your preferred region
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro" # Free Tier eligible
}

variable "key_name" {
  description = "Name of the EC2 Key Pair to use for SSH access."
  type        = string
  # set it via a terraform.tfvars file
}

variable "project_name" {
  description = "A name prefix for resources."
  type        = string
  default     = "ecommerce-web"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed for SSH access. Use your IP for better security: 'xx.xxx.xx.xxx/32'."
  type        = list(string)
  # set it via a terraform.tfvars file
}
