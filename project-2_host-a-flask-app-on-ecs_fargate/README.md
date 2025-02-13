# Host a Flask Application on AWS ECS Fargate

## Architecture Diagram

![Architecture Diagram](./architecture-diagram/host-website-on-ecr_fargate.PNG)


**Project Overview:**

We'll create a simple Python Flask web application, containerize it with Docker, deploy it to AWS Fargate using Terraform and Jenkins, and set up monitoring with Prometheus and Grafana.

**Step 1: Set Up AWS Credentials and Terraform**

1.  **Install the AWS CLI:**  Follow the instructions here: [https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2.  **Configure the AWS CLI:** Run `aws configure` and provide your AWS Access Key ID, Secret Access Key, default region (e.g., `us-east-1`), and output format (e.g., `json`). Make sure the IAM user/role you are using has the necessary permissions to create resources (EC2, ECS, IAM, etc.).  For simplicity in this project, grant AdministratorAccess, but for real-world scenarios, *strictly limit* the permissions to only what's needed.
3.  **Install Terraform:** Follow the instructions here: [https://www.terraform.io/downloads](https://www.terraform.io/downloads)
4.  **Verify Installation:** Open a terminal and run `terraform --version`.

**Step 2: Create a Simple Python Flask Web Application**

Create a directory named `project-2_host-a-website-on-ecs_fargate`. Inside this directory, create the following files:

*   `app.py`:

```python
# flask-app/app.py
from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello():
    return f"Hello from my awesome app!  Hostname: {os.uname()[1]}"

if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
```

*   `requirements.txt`:

```
Flask
```

**Step 3: Dockerize the Flask Application**

Create a `Dockerfile` in the `project-2_host-a-website-on-ecs_fargate` directory:

```dockerfile
# project-2_host-a-website-on-ecs_fargate/Dockerfile
FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8080

CMD ["python", "app.py"]
```

Build and test the Docker image locally:

```bash
cd project-2_host-a-website-on-ecs_fargate
docker build -t project-2_host-a-website-on-ecs_fargate .
docker run -d -p 8080:8080 project-2_host-a-website-on-ecs_fargate
```

Open your web browser and go to `http://localhost:8080`.  You should see the "Hello" message.

![Test Docker Locally](./images/build-and-test-docker-locally.PNG)

**Step 4: Create Terraform Modules for Infrastructure Deployment**

Create a directory named `terraform` in the `project-2_host-a-website-on-ecs_fargate` directory.  Inside this directory, create the following files:

*   `terraform/main.tf`:  This will orchestrate the module calls.

```terraform
# terraform/main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Or your desired version
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}
```
* Run the following terraform commands to confirm that there are no errors in the code;

```bash
cd terraform
```

```bash
terraform init
```

```bash
terraform fmt
```

```bash
terraform validate
```

* Configure the Terraform Modules for `VPC`, `ECS Cluster`, `Fargate Service`, `Prometheus`, `Grafana`;

```terraform
# Module for VPC
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

# Module for ECS Cluster
module "ecs" {
  source = "./modules/ecs"
  name = "my-ecs-cluster"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets_ids # Use private subnets for ECS Fargate
}

# Module for Fargate Service
module "fargate" {
  source = "./modules/fargate"
  cluster_name = module.ecs.cluster_name
  task_definition_name = "host-flask-app-on-ecs-fargate"
  container_name = "flask-app-on-ecs-fargate"
  container_image = "dbekoe1/flask-app-on-ecs-fargate:latest" # Replace!  Push the image to Docker Hub
  container_port = 8080
  subnet_ids = module.vpc.private_subnets_ids
  security_group_ids = module.vpc.security_group_ids # Use SG from the ECS module
  task_definition_cpu = 256
  task_definition_memory = 512
}

# Module for Prometheus
module "prometheus" {
  source = "./modules/prometheus"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets_ids
  security_group_ids = module.vpc.security_group_ids # Use SG from ECS module
}
```

*   Create a directory named `modules` inside the `terraform` directory.  Inside this directory, we'll define our modules.

**Create Terraform Modules:**

*   `terraform/modules/vpc/main.tf`:

```terraform
# terraform/modules/vpc/main.tf
resource "aws_vpc" "ecs_fargate" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "ecs-fargate-vpc"
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.ecs_fargate.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "ecs-fargate-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.ecs_fargate.id
  tags = {
    Name = "ecs-fargate-igw"
  }
}

resource "aws_route_table" "ecs_fargate" {
  vpc_id = aws_vpc.ecs_fargate.id

  tags = {
    Name = "ecs-fargate-route-table"
  }
}

resource "aws_route" "privateigw-route" {
  route_table_id = aws_route_table.ecs_fargate.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.ecs_fargate.id
}

output "vpc_id" {
  value = aws_vpc.ecs_fargate.id
}

output "private_subnets_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
} 
```

* Run the following terraform commands to confirm that there are no errors in the code;

```bash
terraform fmt
```

```bash
terraform validate
```

*   `terraform/modules/vpc/variables.tf`:

```terraform
# terraform/modules/vpc/variables.tf
variable "vpc_cidr" {
  type = string
  description = "CIDR block for the VPC"
}

variable "availability_zones" {
  type = list(string)
  description = "List of availability zones"
}
```
* Run the following terraform commands to confirm that there are no errors in the code;

```bash
terraform fmt
```

```bash
terraform validate
```
