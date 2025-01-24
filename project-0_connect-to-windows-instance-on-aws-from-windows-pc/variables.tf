# Terraform variables for AWS EC2 instance

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
}
variable windows-ec2-cidr {
  type        = string
  default     = "10.0.0.0/16"
  description = "windows instance cidr"
}