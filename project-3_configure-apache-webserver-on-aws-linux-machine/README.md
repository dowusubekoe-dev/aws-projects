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
