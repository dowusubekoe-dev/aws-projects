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
    default = "ami-04f77c9cd94746b09" # Microsoft Windows Server 2019 Base - us-east-1
   }

   variable "key_name" {
    description = "Key pair name used for instance"
    default     = "aws-terraform-key-pair"
  }
   ```