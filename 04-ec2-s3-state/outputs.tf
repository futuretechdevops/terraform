output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.example.private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.example.public_ip}"
}

output "state_backend_info" {
  description = "Information about the remote state backend"
  value = {
    bucket         = "my-terraform-state-bucket-unique-12345"
    key            = "ec2/terraform.tfstate"
    dynamodb_table = "terraform-lock-table"
  }
}

