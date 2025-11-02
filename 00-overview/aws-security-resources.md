# AWS Security Resources

## IAM (Identity and Access Management)
**Purpose**: User and permission management
**Terraform Resource**: `aws_iam_user`, `aws_iam_role`, `aws_iam_policy`
**Use Cases**: Access control, service permissions
**Example**:
```hcl
resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
```

## KMS (Key Management Service)
**Purpose**: Encryption key management
**Terraform Resource**: `aws_kms_key`
**Use Cases**: Data encryption, key rotation
**Example**:
```hcl
resource "aws_kms_key" "encryption" {
  description = "Encryption key for sensitive data"
}
```

## Secrets Manager
**Purpose**: Secure storage for secrets
**Terraform Resource**: `aws_secretsmanager_secret`
**Use Cases**: Database passwords, API keys
**Example**:
```hcl
resource "aws_secretsmanager_secret" "db_password" {
  name = "database-password"
}
```

## Certificate Manager (ACM)
**Purpose**: SSL/TLS certificate management
**Terraform Resource**: `aws_acm_certificate`
**Use Cases**: HTTPS certificates, domain validation
**Example**:
```hcl
resource "aws_acm_certificate" "ssl" {
  domain_name       = "example.com"
  validation_method = "DNS"
}
```

## WAF (Web Application Firewall)
**Purpose**: Web application protection
**Terraform Resource**: `aws_wafv2_web_acl`
**Use Cases**: SQL injection protection, DDoS mitigation
**Example**:
```hcl
resource "aws_wafv2_web_acl" "protection" {
  name  = "web-protection"
  scope = "REGIONAL"
}
```

## GuardDuty
**Purpose**: Threat detection service
**Terraform Resource**: `aws_guardduty_detector`
**Use Cases**: Security monitoring, anomaly detection
**Example**:
```hcl
resource "aws_guardduty_detector" "main" {
  enable = true
}
```

## Security Hub
**Purpose**: Centralized security findings
**Terraform Resource**: `aws_securityhub_account`
**Use Cases**: Security compliance, finding aggregation
**Example**:
```hcl
resource "aws_securityhub_account" "main" {
  enable_default_standards = true
}
```
