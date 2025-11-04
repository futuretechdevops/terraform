provider "aws" {
  region = "ap-south-1"
}

# Instance that might need replacement
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Web Server - Version 1</h1>" > /var/www/html/index.html
    echo "Created at: $(date)" >> /var/www/html/index.html
  EOF
  )
  
  tags = {
    Name    = "replace-example-web"
    Version = "1.0"
  }
}

# Multiple instances for replace with count
resource "aws_instance" "workers" {
  count         = 3
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  tags = {
    Name = "worker-${count.index + 1}"
    Role = "worker"
  }
}

# Instances with for_each for selective replacement
variable "environments" {
  default = {
    dev     = "t2.micro"
    staging = "t2.small"
    prod    = "t3.medium"
  }
}

resource "aws_instance" "env_instances" {
  for_each      = var.environments
  ami           = data.aws_ami.amazon_linux.id
  instance_type = each.value
  
  tags = {
    Name        = "replace-${each.key}"
    Environment = each.key
  }
}

# Launch template for replacement scenarios
resource "aws_launch_template" "app" {
  name_prefix   = "replace-example-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    echo "Launch template version: 1.0" > /tmp/version.txt
    echo "Created: $(date)" >> /tmp/version.txt
  EOF
  )
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "replace-lt-instance"
      Version = "1.0"
    }
  }
}

# Auto Scaling Group using launch template
resource "aws_autoscaling_group" "app" {
  name                = "replace-example-asg"
  vpc_zone_identifier = data.aws_subnets.default.ids
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "replace-asg-instance"
    propagate_at_launch = true
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

output "replace_commands" {
  description = "Commands to replace resources"
  value = {
    single_instance = "terraform apply -replace='aws_instance.web'"
    specific_worker = "terraform apply -replace='aws_instance.workers[1]'"
    env_instance    = "terraform apply -replace='aws_instance.env_instances[\"dev\"]'"
    launch_template = "terraform apply -replace='aws_launch_template.app'"
    multiple_resources = "terraform apply -replace='aws_instance.web' -replace='aws_launch_template.app'"
  }
}

output "instance_info" {
  value = {
    web_instance_id = aws_instance.web.id
    worker_ids      = aws_instance.workers[*].id
    env_instance_ids = { for k, v in aws_instance.env_instances : k => v.id }
    launch_template_id = aws_launch_template.app.id
  }
}
