# Create Linux Server on AWS with Terraform

## Pequisites:

1.  **AWS Account:** You need an active AWS account: ![Create AWS Free-Tier Account](https://aws.amazon.com/resources/create-account/)

2. **Terraform Installed:** Download and install Terraform from the official website: ![Terraform Official Website](https://www.terraform.io/downloads.html)

3. **AWS CLI Installed and Configured for Linux:** Ensure the ![AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/install-linux.html) is installed and configured with your credentials using `aws configure`.

4. **Basic Linux and Cloud Concepts:** Familiarity with basic Linux commands and cloud computing concepts will be helpful.


## Step-by-Step Guide:

1. **Create a Terraform Project Directory**

Create a new directory for your Terraform configuration files. Let's name it `project-1_creating-linux-server-on-aws`:

```bash
    mkdir project-1_creating-linux-server-on-aws
    cd project-1_creating-linux-server-on-aws
```

2. **Add Terraform Code**

Update the `main.tf`, `variable.tf` and `provider.tf` files before initializing providers `registry.terraform.io/hashicorp/aws`.

**variables.tf**

```hcl
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
}

variable "cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

```

**provider.tf**

```hcl
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

```

**main.tf**

``hcl
resource "aws_vpc" "project-1-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "project-1-vpc"
  }
}

```



