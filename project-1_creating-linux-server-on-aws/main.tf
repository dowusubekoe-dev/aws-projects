# Create a VPC 
resource "aws_vpc" "project-1-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "project-1-vpc"
  }
}

# Create a subnet
resource "aws_subnet" "project-1-subnet" {
  vpc_id            = aws_vpc.project-1-vpc.id
  cidr_block        = var.cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "project-1-subnet-public"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "project-1-igw" {
  vpc_id = aws_vpc.project-1-vpc.id

  tags = {
    Name = "project-1-igw"
  }
}