# AWS Application Services

## API Gateway
**Purpose**: API management and deployment
**Terraform Resource**: `aws_api_gateway_rest_api`
**Use Cases**: REST APIs, HTTP APIs, WebSocket APIs
**Example**:
```hcl
resource "aws_api_gateway_rest_api" "main" {
  name        = "my-api"
  description = "Main application API"
}
```

## CloudFront
**Purpose**: Content delivery network (CDN)
**Terraform Resource**: `aws_cloudfront_distribution`
**Use Cases**: Static content delivery, global acceleration
**Example**:
```hcl
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.content.bucket_domain_name
    origin_id   = "S3-content"
  }
  enabled = true
}
```

## Route 53
**Purpose**: DNS web service
**Terraform Resource**: `aws_route53_zone`, `aws_route53_record`
**Use Cases**: Domain management, DNS routing
**Example**:
```hcl
resource "aws_route53_zone" "main" {
  name = "example.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web.public_ip]
}
```

## SES (Simple Email Service)
**Purpose**: Email sending and receiving
**Terraform Resource**: `aws_ses_domain_identity`
**Use Cases**: Transactional emails, marketing emails
**Example**:
```hcl
resource "aws_ses_domain_identity" "main" {
  domain = "example.com"
}
```

## Cognito
**Purpose**: User authentication and authorization
**Terraform Resource**: `aws_cognito_user_pool`
**Use Cases**: User management, OAuth, SAML
**Example**:
```hcl
resource "aws_cognito_user_pool" "users" {
  name = "app-users"
}
```

## Step Functions
**Purpose**: Serverless workflow orchestration
**Terraform Resource**: `aws_sfn_state_machine`
**Use Cases**: Complex workflows, microservice coordination
**Example**:
```hcl
resource "aws_sfn_state_machine" "workflow" {
  name     = "data-processing"
  role_arn = aws_iam_role.step_functions.arn
  definition = jsonencode({
    Comment = "Data processing workflow"
    StartAt = "ProcessData"
    States = {
      ProcessData = {
        Type = "Task"
        Resource = aws_lambda_function.processor.arn
        End = true
      }
    }
  })
}
```

## AppSync
**Purpose**: Managed GraphQL service
**Terraform Resource**: `aws_appsync_graphql_api`
**Use Cases**: GraphQL APIs, real-time subscriptions
**Example**:
```hcl
resource "aws_appsync_graphql_api" "main" {
  authentication_type = "API_KEY"
  name                = "my-graphql-api"
}
```
