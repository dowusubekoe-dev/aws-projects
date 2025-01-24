variable "aws_region" {
     description = "AWS region to deploy in"
     default     = "us-east-1"
   }

   variable "instance_type" {
     description = "EC2 instance type"
     default     = "t2.micro"
   }

   variable "ami_id" {
    description = "Windows AMI id to use"
    default = "ami-04f77c9cd94746b09" # Microsoft Windows Server 2019 Base - us-east-1
   }

   variable "key_name" {
    description = "Key pair name used for instance"
    default     = "aws-terraform-key-pair"
  }