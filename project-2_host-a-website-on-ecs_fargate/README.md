# Host a Website on AWS ECS Fargate

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

![Test Docker Locally](./architecture-diagram/test-docker-locally.PNG)