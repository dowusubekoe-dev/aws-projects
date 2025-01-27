**Challenges 1**

1. Keypair import error

```bash
Error: importing EC2 Key Pair (aws-terraform-kp): operation error EC2: ImportKeyPair, https response error StatusCode: 400, RequestID: d533a85c-375a-4a62-a160-8d216720b6e7, api error InvalidKeyPair.Duplicate: The keypair already exists
│
│   with aws_key_pair.aws-terraform-keypair,
│   on main.tf line 93, in resource "aws_key_pair" "aws-terraform-keypair":
│   93: resource "aws_key_pair" "aws-terraform-keypair" {
```
**Understanding the Problem:**

aws_key_pair Resource: The Terraform aws_key_pair resource is designed to either create a new key pair or import an existing one based on the key_name argument. In this case, you are trying to create one as your intention was to use terraform to generate the keypair however a keypair with this name already exists, so terraform tries to import it. The import fails as the API does not allow you to import a keypair if a keypair with that name already exists.

InvalidKeyPair.Duplicate: The AWS API specifically states that the key pair name is already in use, and you cannot create another one with the same name.

**Solution**

If you already have a key pair named "terraform-aws-keypair" that you intend to use, you should not try to create it with Terraform. Instead, you should just reference it by name in the aws_instance resource.

Remove the aws_key_pair Resource: Remove the entire aws_key_pair block from your main.tf file.

Use the key_name in the aws_instance resource: Ensure your aws_instance resource references the existing key pair.

1. Remove the aws_key_pair Resource: Remove the entire aws_key_pair block from your main.tf file.
2. 2Use the key_name in the aws_instance resource: Ensure your aws_instance resource references the existing key pair.

```hcl
resource "aws_instance" "windows_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_rdp.id]
  key_name               = var.key_name # Use the existing keypair name from variable
  associate_public_ip_address = true
   tags = {
      Name = "Windows-server"
    }
}
```

3. Make sure you also define key_name in your variables.tf

```hcl
variable "key_name" {
       description = "Key pair name used for instance"
       default     = "aws-terraform-kp" # Replace with existing keypair name from AWS console
   }
```

**Challenge 2**

2. Remote Desktop Connetion error

![Remote Desktop Connection](./images/remote-desktop-error.PNG)

- Remote Access is Not Enabled on the Server:

**Problem:** The Remote Desktop feature may not be enabled on the Windows Server instance itself. This could happen if you didn't configure it in your user data or if it was disabled manually after the instance was launched.

**Solution:**
Check the user data script: Verify the user data script that enables RDP access. You should include the following to enable remote desktop in the **user_data**.

```ps1
# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0

# Enable Remote Desktop firewall rule
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

**Update Security Group for RDP**

```hcl
resource "aws_security_group" "allow_rdp" {
  name        = "allow-rdp"
  description = "Allow RDP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = length(var.allowed_rdp_cidrs) > 0 ? var.allowed_rdp_cidrs : [ "${chomp(data.http.myip.response_body)}/32" ]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =  length(var.allowed_rdp_cidrs) > 0 ? var.allowed_rdp_cidrs : [ "${chomp(data.http.myip.response_body)}/32" ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-rdp"
  }
}

```