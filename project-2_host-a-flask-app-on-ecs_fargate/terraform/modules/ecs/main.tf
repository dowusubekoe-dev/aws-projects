resource "aws_ecs_cluster" "main" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE"]
}

resource "aws_security_group" "ecs_tasks" {
  name = "ecs-tasks-security-group"
  description = "Allow inbound access from the ECS task only"
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port = 65535 # Adjust as needed, can be more specific
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In real world, lock down to trusted IPs
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "security_group_id" {
  value = aws_security_group.ecs_tasks.id
}