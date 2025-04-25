# terraform-apache-ec2/outputs.tf

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance (Elastic IP)."
  value       = aws_eip.web_server_eip.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.web_server.id
}

output "website_url" {
  description = "URL to access the Apache web server."
  value       = "http://${aws_eip.web_server_eip.public_ip}"
}

output "ssh_command" {
  description = "Command to SSH into the instance (replace 'path/to/your-key.pem' with your actual key file path)."
  value       = "ssh -i path/to/your-key.pem ec2-user@${aws_eip.web_server_eip.public_ip}"
}

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the created public subnets."
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "security_group_id" {
  description = "ID of the created Security Group."
  value       = aws_security_group.web_server_sg.id
}