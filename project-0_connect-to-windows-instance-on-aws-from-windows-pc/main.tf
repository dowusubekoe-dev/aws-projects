terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
       }
     }
   }

   provider "aws" {
     region = var.aws_region
   }

   # Create VPC
   resource "aws_vpc" "main" {
     cidr_block = "10.0.0.0/16"
     tags = {
       Name = "main-vpc"
     }
   }

   # Create Internet Gateway
    resource "aws_internet_gateway" "gw" {
     vpc_id = aws_vpc.main.id

     tags = {
       Name = "main-igw"
     }
   }

    # Create Route Table
   resource "aws_route_table" "public_route_table" {
     vpc_id = aws_vpc.main.id

     route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
      }

     tags = {
       Name = "main-route-table"
     }
   }

   # Create Subnet
   resource "aws_subnet" "public_subnet" {
     vpc_id            = aws_vpc.main.id
     cidr_block        = "10.0.1.0/24"
     availability_zone = "${var.aws_region}a"
      map_public_ip_on_launch = true

    tags = {
        Name = "main-public-subnet"
      }
   }

   # Associate Route Table with Subnet
   resource "aws_route_table_association" "public_subnet_association" {
     subnet_id      = aws_subnet.public_subnet.id
     route_table_id = aws_route_table.public_route_table.id
   }

   # Create Security Group for RDP
   resource "aws_security_group" "allow_rdp" {
     name        = "allow-rdp"
     description = "Allow RDP inbound traffic"
     vpc_id      = aws_vpc.main.id

     ingress {
       from_port   = 3389
       to_port     = 3389
       protocol    = "tcp"
       cidr_blocks = ["0.0.0.0/0"] #Restrict this to your IP for production
     }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
      }

      tags = {
        Name = "allow-rdp"
      }
   }
   # Create Key Pair
   resource "aws_key_pair" "key" {
      key_name   = var.key_name
      public_key = tls_private_key.key.public_key_openssh
   }

  resource "tls_private_key" "key" {
     algorithm = "RSA"
       rsa_bits  = 4096
  }

   # Create Windows EC2 Instance
   resource "aws_instance" "windows_server" {
     ami                    = var.ami_id
     instance_type          = var.instance_type
     subnet_id              = aws_subnet.public_subnet.id
     vpc_security_group_ids = [aws_security_group.allow_rdp.id]
     key_name               = aws_key_pair.key.key_name
     associate_public_ip_address = true
      tags = {
        Name = "Windows-server"
      }
   }