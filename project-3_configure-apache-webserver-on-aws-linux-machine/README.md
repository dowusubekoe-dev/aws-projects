
# Deploy Apache Web Server on AWS EC2 with Terraform

## 1. Project Objective & Scenario

### Objective (Terraform Focused)

This project automates the deployment of a secure Apache web server running on an Amazon Linux 2 EC2 instance within a custom AWS Virtual Private Cloud (VPC). It utilizes Terraform for Infrastructure as Code (IaC) to ensure repeatable, consistent, and version-controlled infrastructure provisioning.

### Scenario

An E-Commerce startup company, specializing in tech gadgets, needs to launch their online platform. They've chosen AWS for its scalability and robustness, specifically targeting a Linux EC2 instance. The goal is to establish a stable, secure, and responsive website foundation capable of handling growing customer traffic and safeguarding data in the competitive online tech market. This Terraform project builds that foundational infrastructure.

## 2. Core Functionality & Description

This Terraform configuration accomplishes the following:

1. **Provisions Custom Networking:** Creates a dedicated VPC with public subnets across two Availability Zones, an Internet Gateway, and route tables for controlled internet access.
2. **Launches Secure EC2 Instance:** Deploys an EC2 instance using a specified Amazon Machine Image (AMI) within one of the public subnets.
3. **Installs Apache:** Uses EC2 User Data to automatically update the instance, install the Apache HTTP Server (`httpd`) and `mod_ssl` (for potential future HTTPS), start the service, and enable it on boot.
4. **Configures Firewall Rules:**
    * Sets up an AWS Security Group to allow inbound HTTP (port 80), HTTPS (port 443) from anywhere, and SSH (port 22) strictly from a specified IP address.
    * Configures the instance's internal firewall (`firewalld` on Amazon Linux 2) via User Data to permit HTTP and HTTPS traffic.
5. **Assigns Static IP:** Allocates an Elastic IP (EIP) and associates it with the EC2 instance for a stable, predictable public IP address.
6. **Parameterizes Configuration:** Uses Terraform variables (`.tfvars`) to manage environment-specific settings like region, instance type, AMI ID, key pair name, and allowed SSH IP, promoting reusability and security.

## 3. Technologies Used

* **AWS (Amazon Web Services):**
  * **VPC (Virtual Private Cloud):** Isolated network environment.
  * **Subnets:** Public network segments within the VPC.
  * **Internet Gateway (IGW):** Enables internet access for the VPC.
  * **Route Tables:** Controls network traffic routing.
  * **EC2 (Elastic Compute Cloud):** Virtual Server hosting the Apache application.
  * **Security Groups:** Instance-level stateful firewall.
  * **Elastic IP (EIP):** Static public IPv4 address.
  * **IAM (Implicit):** Permissions are required for Terraform/AWS CLI user/role.
* **Terraform:** Infrastructure as Code (IaC) tool (v1.x+).
* **Apache HTTP Server:** Web server software (`httpd`).
* **Amazon Linux 2:** Operating System for the EC2 instance (configurable via `ami_id`).

## 4. Key Terraform Concepts Utilized

* **Providers:** Configuring the AWS provider (`hashicorp/aws`).
* **Resources:** Defining AWS components (`aws_vpc`, `aws_subnet`, `aws_instance`, `aws_security_group`, `aws_eip`, etc.).
* **Variables:** Parameterizing the configuration (defined in `variables.tf`, values provided in `terraform.tfvars`).
* **Input Variables (`.tfvars`):** Supplying environment-specific or sensitive values securely.
* **Outputs:** Displaying useful information post-deployment (`instance_public_ip`, `website_url`, `ssh_command`).
* **Data Sources:** Querying AWS for information (`aws_availability_zones`).
* **User Data:** Bootstrapping the EC2 instance (installing Apache).
* **Implicit & Explicit Dependencies:** Ensuring resources are created in the correct order (`depends_on`).

## 5. Prerequisites

Before deployment, ensure you have:

1. **AWS Account:** Active account with permissions to create VPC, EC2, EIP, Security Group, and related resources.
2. **AWS CLI Installed & Configured:**
    * Install: [AWS CLI Installation Guide](https://aws.amazon.com/cli/)
    * Configure: Run `aws configure` and provide your Access Key ID, Secret Access Key, default region, and output format. Terraform uses these credentials.
3. **Terraform CLI Installed:**
    * Install: [Terraform Installation Guide](https://developer.hashicorp.com/terraform/downloads) (v1.x or later recommended). Verify with `terraform version`.
4. **EC2 Key Pair:**
    * An existing EC2 Key Pair in your target AWS region (e.g., `us-east-1`).
    * Note the **exact name** of the key pair.
    * Possess the corresponding private key file (`.pem` or `.ppk`) locally for SSH access. **Never commit your private key.**
5. **Git (Optional):** For cloning the project repository.

## 6. Project Structure

```bash
terraform-apache-ec2/
├── main.tf                 # Core infrastructure resource definitions
├── variables.tf            # Input variable declarations
├── outputs.tf              # Output value definitions
├── terraform.tfvars.example # Example variable values (safe for Git)
├── terraform.tfvars        # Actual variable values (KEEP PRIVATE - add to .gitignore!)
├── .gitignore              # Specifies intentionally untracked files Git should ignore
└── README.md               # This file
```

## 7. Configuration (`terraform.tfvars`)

Sensitive or environment-specific variables are managed via a `terraform.tfvars` file. **This file should *not* be committed to version control.**

**Setup Steps:**

1. **Copy the Example:** Create your personal configuration file from the example provided:

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

2. **Edit `terraform.tfvars`:** Open the newly created `terraform.tfvars` file and replace the placeholder values with your actual configuration details.

    *Sample `terraform.tfvars.example` (placeholders):*

    ```hcl
    # terraform.tfvars.example
    # --- AWS Provider Configuration ---
    aws_region = "us-east-1"

    # --- EC2 Instance Configuration ---
    # Find a suitable AMI ID in your chosen region (e.g., latest Amazon Linux 2 HVM)
    ami_id        = "ami-xxxxxxxxxxxxxxxxx" # Replace with a valid AMI ID for your region
    instance_type = "t2.micro"
    key_name      = "your-key-pair-name"    # Replace with your EC2 Key Pair name

    # --- Security Configuration ---
    # Replace with YOUR actual public IP address/range for secure SSH access
    # Find your IP: curl ifconfig.me || curl ipinfo.io/ip
    ssh_allowed_cidr = ["YOUR_IP_ADDRESS/32"]

    # --- Networking Configuration ---
    vpc_cidr_block           = "10.0.0.0/16"
    public_subnet_a_cidr_block = "10.0.1.0/24"
    public_subnet_b_cidr_block = "10.0.2.0/24"

    # --- Optional: Override Default Variables ---
    # project_name = "my-custom-project-prefix"
    ```

3. **Security Best Practice (SSH CIDR):** 🛡️ The `ssh_allowed_cidr` variable is crucial for security. Setting it to your specific IP address (`["YOUR_IP_ADDRESS/32"]`) significantly limits potential unauthorized access compared to allowing SSH from anywhere (`["0.0.0.0/0"]`).

4. **`.gitignore`:** Ensure your `.gitignore` file correctly ignores `terraform.tfvars` and other sensitive Terraform files:

    ```gitignore
    # Local .terraform directories
    **/.terraform/*

    # Terraform state files
    *.tfstate
    *.tfstate.*

    # Crash log files
    crash.log
    crash.*.log

    # Exclude terraform.tfvars to avoid committing sensitive values
    terraform.tfvars
    *.tfvars.json
    *.auto.tfvars
    *.auto.tfvars.json

    # Terraform plan output files
    *.tfplan

    # Override files
    override.tf
    override.tf.json
    *_override.tf
    *_override.tf.json

    # Private key files
    *.pem
    *.ppk

    # Instance Lock Files
    .terraform.lock.hcl
    ```

## 8. Deployment Steps

Navigate to the project directory (`terraform-apache-ec2/`) in your terminal and run the following commands:

1. **Initialize Terraform:** Downloads the required AWS provider plugin.

    ```bash
    terraform init
    ```

2. **Validate Configuration:** Checks syntax and configuration validity.

    ```bash
    terraform validate
    ```

3. **Plan Deployment:** Creates an execution plan showing what resources will be created, changed, or destroyed. **Review this carefully.**

    ```bash
    terraform plan
    ```

4. **Apply Deployment:** Provisions the infrastructure on AWS according to the plan. Requires confirmation.

    ```bash
    terraform apply
    ```

    Enter `yes` when prompted to proceed.

## 9. Verification

After a successful `terraform apply`:

1. **Check Outputs:** Terraform will display the values defined in `outputs.tf`. Note the `website_url` and `ssh_command`.
2. **Access Web Server:** Open the `website_url` (e.g., `http://YOUR_ELASTIC_IP`) in your browser. You should see the default Apache test page generated by the User Data script. *Allow a minute or two post-apply for the instance boot and Apache startup.*
3. **SSH Access:** Use the `ssh_command` output to connect. Replace `path/to/your-key.pem` with the actual path to your private key file.

    ```bash
    # Example using the key name specified in terraform.tfvars
    ssh -i path/to/your-key-pair-name.pem ec2-user@YOUR_ELASTIC_IP
    ```

    *(Remember to set secure permissions for your key file: `chmod 400 path/to/your-key-pair-name.pem`)*

## 10. Cleanup

To avoid incurring further AWS costs, destroy the provisioned infrastructure when finished:

1. **Run Destroy Command:**

    ```bash
    terraform destroy
    ```

2. **Confirm:** Review the resources to be destroyed and enter `yes` when prompted.

## 11. Terraform Code Overview

* **`main.tf`:** Defines all the AWS resources (VPC, subnets, IGW, route tables, security group, EC2 instance, EIP) and their configurations, including the user data script for Apache installation.
* **`variables.tf`:** Declares all the input variables used in the configuration (e.g., `aws_region`, `instance_type`, `key_name`, `ami_id`). Defines their types and descriptions but generally omits default values for required inputs (which are provided via `terraform.tfvars`).
* **`outputs.tf`:** Specifies the data points that Terraform should display after successfully applying the configuration (e.g., the public IP address, instance ID, website URL).

## 12. AWS Resources Created

This project provisions the following primary AWS resources:

* `aws_vpc` (1)
* `aws_subnet` (2 - Public)
* `aws_internet_gateway` (1)
* `aws_route_table` (1 - Public)
* `aws_route_table_association` (2)
* `aws_security_group` (1)
* `aws_instance` (1 - EC2)
* `aws_eip` (1)
* `aws_eip_association` (1)

## 13. Potential Enhancements & Next Steps

This project provides a solid foundation. Potential future improvements include:

* **HTTPS Configuration:** Implement SSL/TLS using AWS Certificate Manager (ACM) and an Application Load Balancer (ALB).
* **High Availability & Scalability:** Introduce an ALB and an Auto Scaling Group (ASG) across multiple AZs.
* **Database:** Provision an RDS database instance in private subnets.
* **Private Subnets:** Add private subnets for backend resources like databases.
* **NAT Gateway:** Provide outbound internet access for resources in private subnets.
* **Domain Name:** Use Route 53 to point a custom domain to the EIP or ALB.
* **Monitoring:** Integrate CloudWatch Alarms and custom metrics.
* **Configuration Management:** Use Ansible or EC2 Image Builder for more complex application setups.
* **CI/CD Pipeline:** Automate deployment using GitHub Actions, GitLab CI, AWS CodePipeline, etc.
* **Remote State Backend:** Configure Terraform to store state securely in an S3 bucket with locking via DynamoDB.
