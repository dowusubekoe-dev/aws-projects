# Description: This Terraform script creates a VPC, subnet, and an internet gateway for a Windows EC2 instance on AWS.
# It also creates a security group to allow RDP access and a Windows EC2 instance with a web server role.

# Data Source to Get Public IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Create VPC
resource "aws_vpc" "aws-windows-ec2" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "aws-windows-ec2-vpc"
  }
}



# Create Internet Gateway
resource "aws_internet_gateway" "aws-windows-ec2-igw" {
  vpc_id = aws_vpc.aws-windows-ec2.id

  tags = {
    Name = "aws-windows-ec2-igw"
  }
}

# Create Subnet
resource "aws_subnet" "aws-windows-ec2-subnet-1" {
  vpc_id                  = aws_vpc.aws-windows-ec2.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true # Enable public IP assignment

  tags = {
    Name = "aws-windows-ec2-subnet-1"
  }
}

# Create Route Table
resource "aws_route_table" "aws-windows-ec2-rt" {
  vpc_id = aws_vpc.aws-windows-ec2.id

  route {
    cidr_block = "0.0.0.0/0" # Route to the internet
    gateway_id = aws_internet_gateway.aws-windows-ec2-igw.id
  }

  tags = {
    Name = "aws-windows-ec2-rt"
  }
}

# Associate Route Table Association
resource "aws_route_table_association" "aws-windows-ec2-rt-assoc" {
  subnet_id      = aws_subnet.aws-windows-ec2-subnet-1.id
  route_table_id = aws_route_table.aws-windows-ec2-rt.id
}

# Create Security Group
resource "aws_security_group" "aws-windows-ec2-sg" {
  vpc_id = aws_vpc.aws-windows-ec2.id

  # Allow inbound traffic on port 3389 (RDP)
  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"
    # cidr_blocks = ["${var.windows-ec2-cidr}"] # Replace with your IP range
    cidr_blocks = length(var.allowed_rdp_cidrs) > 0 ? var.allowed_rdp_cidrs : ["${chomp(data.http.myip.response_body)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = length(var.allowed_rdp_cidrs) > 0 ? var.allowed_rdp_cidrs : ["${chomp(data.http.myip.response_body)}/32"]
  }

  # Allow outbound traffic to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-rdp-from-aws-windows-ec2-sg"
  }
}

# Create Windows EC2 Instance
resource "aws_instance" "windows_server" {
  ami                         = var.ami_id # Replace with the latest Windows Server AMI ID for your region
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.aws-windows-ec2-subnet-1.id
  security_groups             = [aws_security_group.aws-windows-ec2-sg.id]
  key_name                    = var.key_name # Replace with your key pair name
  associate_public_ip_address = true
  user_data                   = <<-EOF
    <powershell>
    # Install the Web-Server Role
    Install-WindowsFeature -name Web-Server -IncludeManagementTools

    # Create a basic index.html file
    $content = @"
      <!DOCTYPE html>
      <html>
      <head>
          <title>Welcome</title>
      </head>
      <body>
         <h1>Welcome to Windows Server Instance in AWS</h1>
      </body>
      </html>
    "@

    $content | Out-File -Encoding utf8 "C:\inetpub\wwwroot\index.html"

    # Start the web service
    Start-Service W3SVC

   # Enable Remote Desktop
           Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

           # Enable Remote Desktop firewall rule
           Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    </powershell>
  EOF

  tags = {
    Name = "windows-server-instance"
  }
}
