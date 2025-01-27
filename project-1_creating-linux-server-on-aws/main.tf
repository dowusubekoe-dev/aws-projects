# Create a VPC 
resource "aws_vpc" "project-1-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "project-1-vpc"
  }
}