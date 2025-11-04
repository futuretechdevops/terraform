# Terraform Taint

Mark resources for recreation on the next apply.

## Taint Commands

### Mark Resource for Recreation
```bash
# Taint a specific resource
terraform taint aws_instance.web
terraform taint aws_db_instance.example
terraform taint aws_s3_bucket.example

# Taint resource in module
terraform taint module.vpc.aws_vpc.main

# Taint resource with count/for_each
terraform taint 'aws_instance.web[0]'
terraform taint 'aws_instance.web["prod"]'
```

### Remove Taint
```bash
# Untaint a resource
terraform untaint aws_instance.web
```

## When to Use Taint

- **Corrupted Resources**: Database corruption, failed updates
- **Configuration Drift**: Manual changes outside Terraform
- **Security Issues**: Compromised instances
- **Testing**: Force recreation for testing purposes
- **Immutable Infrastructure**: Replace instead of update

## Taint vs Replace

### Taint (Legacy)
```bash
terraform taint aws_instance.web
terraform apply
```

### Replace (Modern - Terraform 0.15.2+)
```bash
terraform apply -replace="aws_instance.web"
```

## Workflow

1. **Identify Problem**: Resource needs recreation
2. **Taint Resource**: Mark for recreation
3. **Plan**: Review what will be recreated
4. **Apply**: Execute the recreation

## Best Practices

- Use `terraform plan` after tainting
- Consider dependencies before tainting
- Use `-replace` flag instead of taint when possible
- Document why resources were tainted
