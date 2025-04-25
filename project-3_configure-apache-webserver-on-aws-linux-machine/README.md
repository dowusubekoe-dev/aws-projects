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

### Step 2: Define Variables

This file defines the input variables for your Terraform configuration, making it reusable and configurable.

```hcl

# terraform-apache-ec2/variables.tf

variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" # Choose your preferred region
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t2.micro" # Free Tier eligible
}

variable "key_name" {
  description = "Name of the EC2 Key Pair to use for SSH access."
  type        = string
  # set it via a terraform.tfvars file
}

variable "project_name" {
  description = "A name prefix for resources."
  type        = string
  default     = "ecommerce-web"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed for SSH access. Use your IP for better security: 'xx.xxx.xx.xxx/32'."
  type        = list(string)
  # set it via a terraform.tfvars file
}

```
