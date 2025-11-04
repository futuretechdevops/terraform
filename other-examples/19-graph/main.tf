provider "aws" {
  region = "ap-south-1"
}

# VPC - Root of dependency chain
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "graph-example-vpc"
  }
}

# Internet Gateway - depends on VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "graph-example-igw"
  }
}

# Subnets - depend on VPC
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "graph-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "graph-private-subnet-${count.index + 1}"
  }
}

# Route table - depends on VPC and IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "graph-public-rt"
  }
}

# Route table associations - depend on subnets and route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security group - depends on VPC
resource "aws_security_group" "web" {
  name        = "graph-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "graph-web-sg"
  }
}

# Security group for database - depends on VPC and web SG
resource "aws_security_group" "db" {
  name        = "graph-db-sg"
  description = "Security group for database"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  
  tags = {
    Name = "graph-db-sg"
  }
}

# DB subnet group - depends on private subnets
resource "aws_db_subnet_group" "main" {
  name       = "graph-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  
  tags = {
    Name = "graph-db-subnet-group"
  }
}

# RDS instance - depends on DB subnet group and security group
resource "aws_db_instance" "main" {
  identifier     = "graph-example-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  db_name          = "graphdb"
  username         = "admin"
  password         = "password123"
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  
  skip_final_snapshot = true
  
  tags = {
    Name = "graph-example-db"
  }
}

# EC2 instances - depend on subnets, security group, and implicitly on DB
resource "aws_instance" "web" {
  count                  = 2
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_endpoint = aws_db_instance.main.endpoint
  }))
  
  tags = {
    Name = "graph-web-${count.index + 1}"
  }
}

# Load balancer - depends on subnets and security group
resource "aws_lb" "main" {
  name               = "graph-example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = aws_subnet.public[*].id
  
  tags = {
    Name = "graph-example-lb"
  }
}

# Target group - independent resource
resource "aws_lb_target_group" "web" {
  name     = "graph-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  health_check {
    path = "/"
  }
}

# Target group attachments - depend on instances and target group
resource "aws_lb_target_group_attachment" "web" {
  count            = length(aws_instance.web)
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

# Load balancer listener - depends on LB and target group
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
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

data "aws_availability_zones" "available" {
  state = "available"
}

output "graph_commands" {
  value = {
    generate_graph = "terraform graph | dot -Tpng > graph.png"
    view_graph     = "terraform graph"
    plan_graph     = "terraform graph -type=plan"
  }
}
