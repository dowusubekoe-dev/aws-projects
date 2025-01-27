variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}