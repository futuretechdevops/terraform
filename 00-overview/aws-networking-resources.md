# AWS Networking Resources

## VPC (Virtual Private Cloud)
**Purpose**: Isolated network environment
**Terraform Resource**: `aws_vpc`
**Use Cases**: Network isolation, custom networking
**Example**:
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

## Subnet
**Purpose**: Network subdivision within VPC
**Terraform Resource**: `aws_subnet`
**Use Cases**: Public/private network segments
**Example**:
```hcl
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```

## Internet Gateway
**Purpose**: Internet access for VPC
**Terraform Resource**: `aws_internet_gateway`
**Use Cases**: Public internet connectivity
**Example**:
```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}
```

## NAT Gateway
**Purpose**: Outbound internet access for private subnets
**Terraform Resource**: `aws_nat_gateway`
**Use Cases**: Private subnet internet access
**Example**:
```hcl
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
}
```

## Security Group
**Purpose**: Virtual firewall for instances
**Terraform Resource**: `aws_security_group`
**Use Cases**: Network access control
**Example**:
```hcl
resource "aws_security_group" "web" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Route Table
**Purpose**: Network traffic routing rules
**Terraform Resource**: `aws_route_table`
**Use Cases**: Custom routing, traffic direction
**Example**:
```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}
```

## Load Balancer
**Purpose**: Distribute traffic across multiple targets
**Terraform Resource**: `aws_lb` (ALB/NLB)
**Use Cases**: High availability, traffic distribution
**Example**:
```hcl
resource "aws_lb" "main" {
  name               = "app-lb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
}
```
