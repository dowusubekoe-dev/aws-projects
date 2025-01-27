# Description: This Terraform script creates a VPC, subnet, and an internet gateway for a Windows EC2 instance on AWS.
# It also creates a security group to allow RDP access and a Windows EC2 instance with a web server role.

# Data Source to Get Public IP


# Create VPC
resource "aws_vpc" "aws-windows-ec2" {
  cidr_block = var.windows-ec2-cidr

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


# Create Subnet
resource "aws_subnet" "aws-windows-ec2-subnet-1" {
  vpc_id                  = aws_vpc.aws-windows-ec2.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true # Enable public IP assignment

  tags = {
    Name = "aws-windows-ec2-subnet-1"
  }
}


# Associate Route Table Association
resource "aws_route_table_association" "aws-windows-ec2-rt-assoc" {
  subnet_id      = aws_subnet.aws-windows-ec2-subnet-1.id
  route_table_id = aws_route_table.aws-windows-ec2-rt.id
}

# Create Security Group for RDP and HTTP
resource "aws_security_group" "allow_rdp" {
  name        = "allow-rdp"
  description = "Allow RDP and HTTP inbound traffic"
  vpc_id      = aws_vpc.aws-windows-ec2.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow RDP from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-rdp"
  }
}

# Create Windows EC2 Instance
resource "aws_instance" "windows_server" {
  ami                         = var.ami_id # Replace with the latest Windows Server AMI ID for your region
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.aws-windows-ec2-subnet-1.id
  security_groups             = [aws_security_group.allow_rdp.id]
  key_name                    = var.key_name # Replace with your key pair name
  associate_public_ip_address = true
  

  tags = {
    Name = "windows-server-instance"
  }
}
