# terraform-apache-ec2/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# --- Networking Infrastructure ---

# Data source to get available Availability Zones in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create Public Subnet in the first AZ
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0] # First AZ
  map_public_ip_on_launch = true                                           # Instances launched here get a public IP by default

  tags = {
    Name = "${var.project_name}-public-subnet-a"
  }
}

# Create Public Subnet in the second AZ
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[1] # Second AZ
  map_public_ip_on_launch = true                                           # Instances launched here get a public IP by default

  tags = {
    Name = "${var.project_name}-public-subnet-b"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create a Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Route for all internet-bound traffic
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate Public Route Table with Public Subnet A
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Associate Public Route Table with Public Subnet B
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# --- Security Group (Update: Associate with our VPC) ---

resource "aws_security_group" "web_server_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP, HTTPS, and SSH traffic"
  vpc_id      = aws_vpc.main.id # <-- Associate with our VPC

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidr # Use the variable defined in tfvars
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# --- EC2 Instance and Related Resources ---

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Define the EC2 Instance (Update: Use var.ami_id)
resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  # User data script remains the same
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd mod_ssl
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Deployed via Terraform in Custom VPC</h1><h2>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</h2><p>Subnet ID: $(curl -s http://169.254.169.254/latest/meta-data/subnet-id)</p><p>AMI ID: $(curl -s http://169.254.169.254/latest/meta-data/ami-id)</p>" > /var/www/html/index.html
              firewall-cmd --permanent --add-service=http
              firewall-cmd --permanent --add-service=https
              firewall-cmd --reload
              EOF

  tags = {
    Name = "${var.project_name}-instance"
  }

  depends_on = [aws_internet_gateway.gw]
}


# Allocate an Elastic IP
resource "aws_eip" "web_server_eip" {
  domain = "vpc" # Correct scope for VPC EIPs

  # Explicitly depend on the Internet Gateway to ensure network path exists
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.project_name}-eip"
  }
}

# Associate the Elastic IP with the EC2 Instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.web_server_eip.id
}