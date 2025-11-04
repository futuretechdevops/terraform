terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Basic null resource for running local commands
resource "null_resource" "local_setup" {
  # Triggers determine when this resource should be recreated
  triggers = {
    timestamp = timestamp()
  }
  
  provisioner "local-exec" {
    command = "echo 'Setting up local environment at ${timestamp()}' >> setup.log"
  }
  
  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Cleaning up local environment at ${timestamp()}' >> cleanup.log"
  }
}

# Null resource that depends on other resources
resource "aws_s3_bucket" "example" {
  bucket = "null-resource-example-${random_id.suffix.hex}"
  
  tags = {
    Name = "null-resource-example"
  }
}

resource "null_resource" "bucket_setup" {
  # This null resource runs after the bucket is created
  depends_on = [aws_s3_bucket.example]
  
  triggers = {
    bucket_name = aws_s3_bucket.example.bucket
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Bucket ${aws_s3_bucket.example.bucket} created successfully"
      aws s3 cp ${path.module}/sample.txt s3://${aws_s3_bucket.example.bucket}/
    EOT
  }
}

# Null resource for conditional execution
variable "deploy_monitoring" {
  description = "Whether to deploy monitoring"
  type        = bool
  default     = true
}

resource "null_resource" "monitoring_setup" {
  count = var.deploy_monitoring ? 1 : 0
  
  triggers = {
    monitoring_config = filemd5("${path.module}/monitoring.conf")
  }
  
  provisioner "local-exec" {
    command = "echo 'Setting up monitoring with config: ${path.module}/monitoring.conf'"
  }
}

# Null resource for complex triggers
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  tags = {
    Name = "null-resource-web"
  }
}

resource "null_resource" "instance_configuration" {
  # Multiple triggers - any change will recreate this resource
  triggers = {
    instance_id   = aws_instance.web.id
    instance_type = aws_instance.web.instance_type
    config_hash   = md5(file("${path.module}/app_config.json"))
  }
  
  # Connection for remote provisioners
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = aws_instance.web.public_ip
  }
  
  provisioner "file" {
    source      = "${path.module}/app_config.json"
    destination = "/tmp/app_config.json"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/app_config.json /etc/app_config.json",
      "sudo systemctl restart myapp || echo 'Service not found, skipping restart'"
    ]
  }
}

# Null resource for time-based triggers
resource "null_resource" "daily_backup" {
  triggers = {
    # This will change daily, causing the resource to be recreated
    date = formatdate("YYYY-MM-DD", timestamp())
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Running daily backup for ${formatdate("YYYY-MM-DD", timestamp())}"
      # Add actual backup commands here
    EOT
  }
}

# Null resource for external API calls
resource "null_resource" "external_notification" {
  depends_on = [aws_instance.web]
  
  triggers = {
    instance_id = aws_instance.web.id
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      curl -X POST https://api.example.com/notify \
        -H "Content-Type: application/json" \
        -d '{"message": "Instance ${aws_instance.web.id} deployed", "timestamp": "${timestamp()}"}'
    EOT
  }
}

# Null resource for file generation
resource "null_resource" "generate_inventory" {
  triggers = {
    instance_id = aws_instance.web.id
    bucket_name = aws_s3_bucket.example.bucket
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      cat > inventory.json << EOF
{
  "timestamp": "${timestamp()}",
  "resources": {
    "instance_id": "${aws_instance.web.id}",
    "instance_ip": "${aws_instance.web.public_ip}",
    "bucket_name": "${aws_s3_bucket.example.bucket}",
    "bucket_arn": "${aws_s3_bucket.example.arn}"
  }
}
EOF
    EOT
  }
}

# Create sample files for the examples
resource "local_file" "sample_txt" {
  content  = "This is a sample file for S3 upload\nCreated at: ${timestamp()}"
  filename = "${path.module}/sample.txt"
}

resource "local_file" "monitoring_conf" {
  content = <<-EOT
[monitoring]
enabled=true
interval=60
metrics=cpu,memory,disk
EOT
  filename = "${path.module}/monitoring.conf"
}

resource "local_file" "app_config" {
  content = jsonencode({
    app_name    = "null-resource-example"
    version     = "1.0.0"
    environment = "development"
    features = {
      logging    = true
      monitoring = var.deploy_monitoring
    }
  })
  filename = "${path.module}/app_config.json"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "null_resource_info" {
  description = "Information about null resources"
  value = {
    local_setup_id         = null_resource.local_setup.id
    bucket_setup_id        = null_resource.bucket_setup.id
    instance_config_id     = null_resource.instance_configuration.id
    daily_backup_id        = null_resource.daily_backup.id
    notification_id        = null_resource.external_notification.id
    inventory_generator_id = null_resource.generate_inventory.id
  }
}

output "usage_examples" {
  description = "Common null resource usage patterns"
  value = {
    local_commands     = "Run local scripts and commands"
    external_apis      = "Call external APIs and webhooks"
    file_generation    = "Generate configuration files"
    conditional_logic  = "Execute based on conditions"
    dependency_control = "Control execution order"
    trigger_based      = "React to resource changes"
  }
}
