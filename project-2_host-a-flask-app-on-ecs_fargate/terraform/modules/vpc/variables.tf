# terraform/modules/vpc/variables.tf
variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones"
  default = ["us-east-1a", "us-east-1b"]
}