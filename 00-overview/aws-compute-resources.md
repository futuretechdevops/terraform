# AWS Compute Resources

## EC2 (Elastic Compute Cloud)
**Purpose**: Virtual servers in the cloud
**Terraform Resource**: `aws_instance`
**Use Cases**: Web servers, application servers, development environments
**Example**:
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
```

## Lambda
**Purpose**: Serverless compute service
**Terraform Resource**: `aws_lambda_function`
**Use Cases**: Event-driven processing, APIs, automation
**Example**:
```hcl
resource "aws_lambda_function" "processor" {
  filename      = "lambda.zip"
  function_name = "data-processor"
  runtime       = "python3.9"
}
```

## ECS (Elastic Container Service)
**Purpose**: Container orchestration service
**Terraform Resource**: `aws_ecs_cluster`, `aws_ecs_service`
**Use Cases**: Microservices, containerized applications
**Example**:
```hcl
resource "aws_ecs_cluster" "main" {
  name = "app-cluster"
}
```

## EKS (Elastic Kubernetes Service)
**Purpose**: Managed Kubernetes service
**Terraform Resource**: `aws_eks_cluster`
**Use Cases**: Container orchestration, cloud-native applications
**Example**:
```hcl
resource "aws_eks_cluster" "main" {
  name     = "my-cluster"
  role_arn = aws_iam_role.cluster.arn
}
```

## Auto Scaling Group
**Purpose**: Automatically scale EC2 instances
**Terraform Resource**: `aws_autoscaling_group`
**Use Cases**: High availability, automatic scaling
**Example**:
```hcl
resource "aws_autoscaling_group" "web" {
  min_size         = 1
  max_size         = 3
  desired_capacity = 2
}
```
