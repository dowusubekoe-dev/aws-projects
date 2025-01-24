# Terraform variables for AWS EC2 instance

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
}
variable "windows-ec2-cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "windows instance cidr"
}
variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Type of EC2 instance"
}
variable "ami_id" {
  type        = string
  default     = "ami-032ec7a32b7fb247c" # Replace with the latest Windows AMI ID for your region
  description = "AMI ID for the Windows instance"
}
variable "key_name" {
  type        = string
  default     = "aws-terraform-kp"
  description = "Name of the key pair for SSH access"
}
variable "allowed_rdp_cidrs" {
  description = "List of CIDR blocks allowed for RDP access. Defaults to current IP address"
  type        = list(string)
  default     = []
}