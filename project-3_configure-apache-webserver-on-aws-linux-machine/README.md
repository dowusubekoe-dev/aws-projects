# Configure Apache Webserver on AWS Linux EC2 Machine

## Objective (Terraform Focused)

Automate the provisioning of an AWS EC2 instance running Amazon Linux 2, configure its security group to allow HTTP/HTTPS and SSH traffic, install and start the Apache web server using user data, and associate an Elastic IP for a stable public address.

## Scenario

An E-Commerce startup company, specializing in tech gadgets, decides to launch their online platform. They opt for AWS, specifically a Linux EC2 instance, for its scalability and robustness. The goal is to establish a stable and responsive website to cater for their growing customer base, ensuring smooth functionality and security in the competitive online tech market.

## Description

1. Setting up and configuring an Apache Webserver on the AWS EC2 instance.

2. Optimizing the performance for high traffic and securing the server with firewalls.

3. Setup with the focus of efficiently handling web traffic and safeguarding customer data.

## Overview & Key Concepts

Key Terraform Concepts we'll Use:

1. Provider: Configure the AWS provider.
2. Resources: Define AWS components like aws_instance, aws_security_group, aws_eip, aws_eip_association.
3. Data Sources: Look up existing information like the latest AMI or default VPC details.
4. Variables: Parameterize configuration (like region, instance type, key name).
5. Outputs: Display useful information after deployment (like the instance's public IP).
6. User Data: Pass a script to the EC2 instance to run on launch (for installing Apache).

## Project Structure

Create a directory for your project, for example, terraform-apache-ec2. Inside this directory, create the following files:

```md
terraform-apache-ec2/
├── main.tf         # Core infrastructure resources
├── variables.tf    # Input variables definitions
├── outputs.tf      # Output values definition
├── userdata.sh     # Apache installation script (optional, can be inline)
└── README.md       # Your updated project README

```

### Step 1: Pre-requisites

1. AWS Account: You need an active AWS account.
2. AWS CLI Configured: Install and configure the AWS CLI with credentials (aws configure). Terraform uses these credentials.
3. Terraform Installed: Download and install the Terraform CLI.
4. EC2 Key Pair: Create an EC2 Key Pair in the AWS region you intend to use. Download the .pem file and note the Key Pair name. You'll need this name for the Terraform configuration. Do not commit your .pem file to Git.

#### Create a .gitignore file for Terraform

```bash
# Local .terraform directories
**/.terraform/*

# Terraform state files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Terraform variable override files
*.tfvars
*.tfvars.json

# Terraform plan output
*.tfplan

# Sensitive/temporary files
*.bak
*.backup
*.log

# Ignore override configs (if any)
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore example templates that shouldn't be used directly
!*.tfvars.example # <--- Referenced in the .gitignore file

```

#### Security Note

Using a default ssh_allowed_cidr allows SSH from any IP. For better security, change the default or override it with your specific IP address (`curl ifconfig.me to find your IP`, then use ["YOUR_IP/32"]) in a `terraform.tfvars` file.

**Create terraform.tfvars file:**

- In the same directory (terraform-apache-ec2/), create a new file named `terraform.tfvars`.
- Add your IP to terraform.tfvars:
- Open the terraform.tfvars file and add the following line, replacing YOUR_ACTUAL_PUBLIC_IP with the IP address you found in running the command `curl ifconfig.me` in the terminal.

✅🛡️ Pro Tip: Always commit a `terraform.tfvars.example` with safe placeholder values to show users what variables they need to set up. Your actual values should be in the `terraform.tfvars` file, which will not be pushed to the remote git repository.

🔐 Make sure you don’t commit your actual terraform.tfvars file that contains real keys or IDs.

```bash
cp terraform.tfvars terraform.tfvars.example
```

### Step 2: Define Variables (variables.tf)

This file defines the input variables for your Terraform configuration, making it reusable and configurable.

```hcl

# terraform-apache-ec2/variables.tf

iable "aws_region" {
  description = "The AWS region to deploy resources in. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "instance_type" {
  description = "The EC2 instance type. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "key_name" {
  description = "Name of the EC2 Key Pair to use for SSH access. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "project_name" {
  description = "A name prefix for resources."
  type        = string
  default     = "ecommerce-web" # Keeping this default is often okay, but can be moved too if desired
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed for SSH access (e.g., ['YOUR_IP/32']). Set in terraform.tfvars."
  type        = list(string)
  # No default - value provided via tfvars
}

# --- Networking Variables ---

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "public_subnet_a_cidr_block" {
  description = "CIDR block for the public subnet in AZ A. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

variable "public_subnet_b_cidr_block" {
  description = "CIDR block for the public subnet in AZ B. Set in terraform.tfvars."
  type        = string
  # No default - value provided via tfvars
}

```

### Step 3: Define Core Resources (main.tf)

This is the main file where you define the AWS resources.

```hcl

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
              echo "<h1>Deployed via Terraform in Custom VPC</h1>
              <h2>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</h2>
              <p>Subnet ID: $(curl -s http://169.254.169.254/latest/meta-data/subnet-id)</p>
              <p>AMI ID: $(curl -s http://169.254.169.254/latest/meta-data/ami-id)</p>" > /var/www/html/index.html
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

```

**User Data**: The user_data block contains a shell script that AWS runs the first time the instance boots. It updates packages, installs Apache (httpd), starts the service, enables it to start on future boots, and creates a simple default index.html page.

### Step 4: Define Outputs (outputs.tf)

This file defines what information Terraform should display after applying the configuration.

```hcl

# terraform-apache-ec2/outputs.tf

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance (Elastic IP)."
  value       = aws_eip.web_server_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance."
  value       = aws_instance.web_server.public_dns # Note: DNS might resolve to EIP or initial public IP depending on timing
}

output "ssh_command" {
  description = "Command to SSH into the instance (replace 'your-key.pem' with your actual key file path)."
  value       = "ssh -i /mnt/e/main-pod/1 - cloud-computing_devops/projects/aws-cloud/aws-projects/aws-iac_keypair.pem ec2-user@${aws_eip.web_server_eip.public_ip}" 
}

output "website_url" {
  description = "URL to access the Apache web server."
  value       = "http://${aws_eip.web_server_eip.public_ip}"
}

```

### Step 5: Deployment using Terraform

1. **Navigate to Directory**: Open your terminal and cd into the terraform-apache-ec2 directory.
2. **Initialize Terraform**: Run terraform init. This downloads the necessary provider plugins (AWS provider in this case).
3. **Validate Configuration**: Run terraform validate. Checks syntax errors in your .tf files.
4. **Plan Deployment**: Run terraform plan -var="key_name=YOUR_KEY_PAIR_NAME".
    - Replace YOUR_KEY_PAIR_NAME with the actual name of the EC2 key pair you created in the prerequisites.
    - This command shows you what resources Terraform will create, modify, or destroy. Review the plan carefully.
    - Alternative for key_name: Create a file named terraform.tfvars and put key_name = "YOUR_KEY_PAIR_NAME" inside it. Then you can just run terraform plan. Do not commit terraform.tfvars if it contains sensitive information.
5. Apply Deployment: If the plan looks good, run terraform apply -var="key_name=YOUR_KEY_PAIR_NAME" (or just terraform apply if using terraform.tfvars).
    - Terraform will ask for confirmation. Type yes and press Enter.
    - Terraform will now create the Security Group, EC2 Instance, Elastic IP, and associate them.
    - Wait for the process to complete. It will display the outputs defined in outputs.tf.

### Step 6: Verification

1. Access Website: Open a web browser and navigate to the website_url shown in the Terraform output (e.g., http://YOUR_ELASTIC_IP). You should see the "Deployed via Terraform" message. It might take a minute or two after apply finishes for the instance to fully boot and start Apache.
2. SSH Access (Optional): Use the ssh_command from the output. Replace path/to/your-key.pem with the actual path to your private key file.
    - Example: ssh -i ~/.ssh/my-aws-key.pem ec2-user@YOUR_ELASTIC_IP
    - Remember to set correct permissions for your .pem file: chmod 400 path/to/your-key.pem.
