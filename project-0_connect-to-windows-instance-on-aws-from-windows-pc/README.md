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

