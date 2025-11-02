# AWS Monitoring & Management Resources

## CloudWatch
**Purpose**: Monitoring and observability service
**Terraform Resource**: `aws_cloudwatch_metric_alarm`, `aws_cloudwatch_log_group`
**Use Cases**: Metrics, logs, alarms, dashboards
**Example**:
```hcl
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  threshold           = "80"
}
```

## CloudTrail
**Purpose**: API call logging and auditing
**Terraform Resource**: `aws_cloudtrail`
**Use Cases**: Compliance, security auditing, troubleshooting
**Example**:
```hcl
resource "aws_cloudtrail" "audit" {
  name           = "audit-trail"
  s3_bucket_name = aws_s3_bucket.logs.bucket
}
```

## Config
**Purpose**: Resource configuration tracking
**Terraform Resource**: `aws_config_configuration_recorder`
**Use Cases**: Compliance monitoring, configuration history
**Example**:
```hcl
resource "aws_config_configuration_recorder" "main" {
  name     = "config-recorder"
  role_arn = aws_iam_role.config.arn
}
```

## SNS (Simple Notification Service)
**Purpose**: Message publishing and delivery
**Terraform Resource**: `aws_sns_topic`
**Use Cases**: Alerts, notifications, decoupling
**Example**:
```hcl
resource "aws_sns_topic" "alerts" {
  name = "system-alerts"
}
```

## SQS (Simple Queue Service)
**Purpose**: Message queuing service
**Terraform Resource**: `aws_sqs_queue`
**Use Cases**: Decoupling, async processing
**Example**:
```hcl
resource "aws_sqs_queue" "tasks" {
  name = "task-queue"
}
```

## EventBridge
**Purpose**: Event-driven architecture
**Terraform Resource**: `aws_cloudwatch_event_rule`
**Use Cases**: Event routing, serverless triggers
**Example**:
```hcl
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "daily-backup"
  schedule_expression = "rate(24 hours)"
}
```

## Systems Manager
**Purpose**: Operational management service
**Terraform Resource**: `aws_ssm_parameter`
**Use Cases**: Parameter store, patch management
**Example**:
```hcl
resource "aws_ssm_parameter" "config" {
  name  = "/app/database/url"
  type  = "String"
  value = "database.example.com"
}
```
