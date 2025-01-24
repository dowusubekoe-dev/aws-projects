# Connect Windows Machine on AWS From Window PC

Below is a step-by-step guide with Terraform code to create a Windows EC2 instance in AWS and connect to it from a Windows laptop. This guide will include the necessary infrastructure components (VPC, Subnet, Security Group, etc.) within the Terraform configuration.

**Prerequisites:**

*   **AWS Account:** As before, you need an active AWS account.
*   **Terraform Installed:** Download and install Terraform from [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html).
*   **AWS CLI Configured:** Configure the AWS CLI on your machine with your AWS credentials.
*   **Windows Laptop:** You'll need a Windows laptop with the Remote Desktop Connection client.
*   **Basic Terraform Knowledge:** Familiarity with Terraform syntax and concepts is beneficial.
*   **Text Editor or IDE:**  To write and manage your Terraform code (e.g., VS Code).
*   **Local Key Pair (`.pem` file):** We will download the key pair using the AWS CLI as part of this process so we can decrypt the admin password.

**Step-by-Step Guide**

**1. Set up Your Terraform Project:**

   1.  **Create a Project Directory:** Create a new directory (folder) for your Terraform project (e.g., `windows-ec2-terraform`).
   2.  **Create `main.tf`:** Inside the directory, create a file named `main.tf`. This file will contain your Terraform configuration code.
   3.  **Create `variables.tf`:** Inside the directory, create a file named `variables.tf`. This will hold configurable variables.
   4.  **Create `outputs.tf`:** Inside the directory, create a file named `outputs.tf`. This will hold the output of important values once terraform is complete

**2.  Add the `variables.tf` Configuration:**
   
   ```terraform
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
    default = "ami-04f77c9cd94xxxxxx" # Microsoft Windows Server 2019 Base - us-east-1
   }

   variable "key_name" {
    description = "Key pair name used for instance"
    default     = "aws-terraform-key-pair"
  }
   ```

**3.  Add the `main.tf` Configuration:**

   Copy the following Terraform code into `main.tf`:

   ```terraform
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
  ```

  **4. Add the `outputs.tf` Configuration:**

   Copy the following Terraform code into `outputs.tf`:

   ```terraform
   output "public_ip" {
     value = aws_instance.windows_server.public_ip
   }

   output "private_key" {
    value = tls_private_key.key.private_key_pem
    sensitive = true
   }
   ```

**5. Initialize Terraform:**

   1.  Open a terminal or command prompt.
   2.  Navigate to the directory containing your `main.tf`, `variables.tf` and `outputs.tf` files.
   3.  Run the command `terraform validate`. The command will validate the code for any errors.
   4.  Run the command `terraform init`. This command initializes the Terraform project and downloads the necessary provider plugins.

**6.  Apply the Terraform Configuration:**

    1.  Run the command `terraform apply`.
    2.  Terraform will display a plan of the resources that will be created.  Review this plan carefully.
    3.  If everything looks correct, type `yes` and press Enter to confirm and create the resources.
    4.  Once terraform has completed, take note of the public_ip value.

**7. Retrieve the Private Key and Save it to a `.pem` file**

   1. Run the command `terraform output` to get the private key.
   2. Copy the sensitive value, and then save it into a file with the name `windows-instance-key.pem`
   3. You may need to remove new lines from the private key string that gets outputted. If you are on a unix system use the command `sed -e :a -e '$!N;s/\n//;ta' windows-instance-key.pem > cleaned-windows-instance-key.pem` to remove them.