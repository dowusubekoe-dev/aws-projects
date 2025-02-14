from diagrams import Diagram, Cluster, Edge
from diagrams.aws.compute import ECS, ECR
from diagrams.aws.network import ALB, VPC, InternetGateway
from diagrams.aws.security import IAM
from diagrams.aws.management import Cloudwatch
from diagrams.programming.framework import Flask
from diagrams.onprem.ci import GithubActions
from diagrams.onprem.vcs import Github
from diagrams.onprem.client import Users, Client
from diagrams.aws.general import User

# Set diagram attributes
graph_attr = {
    "fontsize": "45",
    "bgcolor": "grey"
}

with Diagram("Flask App on ECS Fargate Architecture", show=False, graph_attr=graph_attr):
    # Users and Engineers
    users = Users("End Users")
    engineer = Client("Cloud Engineer")

    # Source Control and CI/CD
    with Cluster("CI/CD Pipeline"):
        github = Github("Source Code")
        actions = GithubActions("GitHub Actions")
        flask = Flask("Flask App")

    # AWS Infrastructure
    with Cluster("AWS Cloud"):
        # Networking
        with Cluster("VPC"):
            igw = InternetGateway("Internet Gateway")
            alb = ALB("Application\nLoad Balancer")
            
            # ECS Cluster
            with Cluster("ECS Cluster"):
                ecs = ECS("ECS Fargate")
                ecr = ECR("Container Registry")

        # Security and Monitoring
        iam = IAM("IAM Roles")
        cloudwatch = Cloudwatch("Monitoring\n& Logs")

    # Access Flow
    users >> Edge(color="blue", label="HTTPS") >> igw >> alb
    engineer >> Edge(color="red", label="SSH/AWS CLI") >> iam
    
    # Development Flow
    engineer >> github
    github >> actions >> ecr
    flask >> ecr

    # Infrastructure Flow
    ecr >> ecs
    alb >> ecs
    iam >> ecs
    ecs >> cloudwatch
    actions >> ecs

    # Monitoring Flow
    engineer >> Edge(color="green", label="Monitoring") >> cloudwatch