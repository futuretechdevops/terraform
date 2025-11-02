# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create Security Group
resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg"
  description = "Security group for web application"
  vpc_id      = aws_vpc.main.id

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Python app port
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create Key Pair (conditional)
resource "aws_key_pair" "webapp" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_name != "" ? var.key_name : "${var.project_name}-key"
  public_key = file(var.public_key_path)

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Get existing key pair (if not creating new one)
data "aws_key_pair" "existing" {
  count    = var.create_key_pair ? 0 : 1
  key_name = var.key_name
}

# User Data Script
locals {
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y python3 python3-pip
    
    # Create Python web application
    cat > /home/ec2-user/app.py << 'EOL'
import http.server
import socketserver
import os

class ColorHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        
        html_content = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Terraform EC2 Web App</title>
            <style>
                body {
                    background: linear-gradient(45deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4);
                    background-size: 400% 400%;
                    animation: gradient 15s ease infinite;
                    font-family: Arial, sans-serif;
                    text-align: center;
                    padding: 50px;
                    margin: 0;
                }
                @keyframes gradient {
                    0% { background-position: 0% 50%; }
                    50% { background-position: 100% 50%; }
                    100% { background-position: 0% 50%; }
                }
                .container {
                    background: rgba(255, 255, 255, 0.9);
                    border-radius: 20px;
                    padding: 40px;
                    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
                    max-width: 600px;
                    margin: 0 auto;
                }
                h1 { color: #333; margin-bottom: 20px; }
                .info { color: #666; margin: 10px 0; }
                .success { color: #27ae60; font-weight: bold; }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>🎉 Terraform EC2 Web Application</h1>
                <p class="success">✅ Successfully deployed with Terraform!</p>
                <div class="info">
                    <p><strong>Instance ID:</strong> """ + os.popen('curl -s http://169.254.169.254/latest/meta-data/instance-id').read() + """</p>
                    <p><strong>Availability Zone:</strong> """ + os.popen('curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone').read() + """</p>
                    <p><strong>Instance Type:</strong> """ + os.popen('curl -s http://169.254.169.254/latest/meta-data/instance-type').read() + """</p>
                    <p><strong>Public IP:</strong> """ + os.popen('curl -s http://169.254.169.254/latest/meta-data/public-ipv4').read() + """</p>
                </div>
                <p>🚀 This colorful page is served by Python from your EC2 instance!</p>
            </div>
        </body>
        </html>
        """
        self.wfile.write(html_content.encode())

PORT = 8000
with socketserver.TCPServer(("", PORT), ColorHandler) as httpd:
    print(f"Server running at port {PORT}")
    httpd.serve_forever()
EOL

    # Make script executable and run
    chmod +x /home/ec2-user/app.py
    chown ec2-user:ec2-user /home/ec2-user/app.py
    
    # Start the application
    nohup python3 /home/ec2-user/app.py > /home/ec2-user/app.log 2>&1 &
    
    # Create systemd service for auto-start
    cat > /etc/systemd/system/webapp.service << 'EOL'
[Unit]
Description=Python Web Application
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/usr/bin/python3 /home/ec2-user/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL

    systemctl enable webapp.service
    systemctl start webapp.service
  EOF
}

# Create EC2 Instance
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.create_key_pair ? aws_key_pair.webapp[0].key_name : var.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = base64encode(local.user_data)

  tags = {
    Name = "${var.project_name}-instance"
  }
}

# Remove outputs from main.tf as they're now in outputs.tf
