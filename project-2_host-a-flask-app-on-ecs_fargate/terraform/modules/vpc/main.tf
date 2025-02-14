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

resource "aws_route" "private_igw_route" {
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