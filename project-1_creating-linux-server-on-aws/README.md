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