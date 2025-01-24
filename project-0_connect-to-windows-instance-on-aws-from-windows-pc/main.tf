# Description: This Terraform script creates a VPC, subnet, and an internet gateway for a Windows EC2 instance on AWS.

# Create VPC
resource "aws_vpc" "aws-windows-ec2" {
  cidr_block = "10.0.0.0/16"

    tags = {
        Name = "aws-windows-ec2-vpc"
    }
  }

# Create Internet Gateway
resource "aws_internet_gateway" "aws-windows-ec2-igw" {
  vpc_id = aws_vpc.aws-windows-ec2.id

    tags = {
        Name = "aws-windows-ec2-igw"
    }
  }

# Create Subnet
resource "aws_subnet" "aws-windows-ec2-subnet-1" {
  vpc_id            = aws_vpc.aws-windows-ec2.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true # Enable public IP assignment
    
    tags = {
        Name = "aws-windows-ec2-subnet-1"
    }
  }

# Create Route Table
resource "aws_route_table" "aws-windows-ec2-rt" {
  vpc_id = aws_vpc.aws-windows-ec2.id

  route {
    cidr_block = "0.0.0.0/0" # Route to the internet
    gateway_id = aws_internet_gateway.aws-windows-ec2-igw.id
  }

    tags = {
        Name = "aws-windows-ec2-rt"
    }
  }

# Associate Route Table Association
resource "aws_route_table_association" "aws-windows-ec2-rt-assoc" {
  subnet_id      = aws_subnet.aws-windows-ec2-subnet-1.id
  route_table_id = aws_route_table.aws-windows-ec2-rt.id
  }

# Create Security Group
resource "aws_security_group" "aws-windows-ec2-sg" {
  vpc_id = aws_vpc.aws-windows-ec2.id

  # Allow inbound traffic on port 3389 (RDP)
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.windows-ec2-cidr}"] # Replace with your IP range
    }

    tags = {
        Name = "allow-rdp-from-aws-windows-ec2-sg"
    }

  # Allow outbound traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create Windows EC2 Instance
resource "aws_instance" "windows_server" {
  ami           = var.ami_id # Replace with the latest Windows Server AMI ID for your region
  instance_type = var.instance_type
  subnet_id     = aws_subnet.aws-windows-ec2-subnet-1.id
  security_groups = [aws_security_group.aws-windows-ec2-sg.id]
  key_name = var.key_name # Replace with your key pair name
  associate_public_ip_address = true

  tags = {
    Name = "windows-server-instance"
  }
}
