# Configuring and Deploying Amazon VPC with Multiple Subnets

## Create the VPC using AWS CLI

```bash
aws ec2 create-vpc --cidr-block 10.0.0.0/22 --region us-east-1 --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=infinitech-main-vpc}]"
```

## Create the Internet Gateway and attach to VPC

```bash
aws ec2 create-internet-gateway --region us-east-1 --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=infinitech-igw}]"
```

```bash
aws ec2 attach-internet-gateway --region us-east-1 --internet-gateway-id igw-0ef301328dc3b0ed6 --vpc-id vpc-024532f043494807d
```

```bash
aws ec2 describe-internet-gateways --region us-east-1
```

## Create Subnet

```bash
aws ec2 create-subnet --region us-east-1 --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=infinitech-pub-subnet}]" --cidr-block 10.0.0.0/25 --vpc-id vpc-024532f043494807d
```

## Create Route Table

```bash
aws ec2 create-route-table --region us-east-1 --vpc-id vpc-024532f043494807d --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=infinitech-pub-route-table}]"
```

## Create Route to the Internet Gateway

```bash
aws ec2 create-route --region us-east-1 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-0ef301328dc3b0ed6 --route-table-id rtb-0109770ca95fe9f85
```

## Associate the Route Table with Subnet (In order to make it Public)

```bash
aws ec2 associate-route-table --region us-east-1 --route-table-id rtb-0109770ca95fe9f85 --subnet-id subnet-06b1be70a49ca09fc
```
