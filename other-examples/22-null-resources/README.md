# Terraform Null Resources

Execute arbitrary actions without managing specific infrastructure resources.

## What are Null Resources?

Null resources don't create actual infrastructure but provide:
- **Provisioner Execution**: Run local or remote commands
- **Dependency Management**: Control execution order
- **Trigger-based Actions**: React to resource changes
- **Conditional Logic**: Execute based on conditions

## Common Use Cases

### 1. Local Commands
- Run scripts and utilities
- Generate configuration files
- Call external APIs
- Perform cleanup tasks

### 2. Remote Configuration
- Configure applications after deployment
- Upload files to instances
- Restart services
- Run database migrations

### 3. Dependency Control
- Ensure proper execution order
- Wait for external conditions
- Coordinate multi-step deployments

### 4. Conditional Execution
- Deploy optional components
- Environment-specific actions
- Feature flag implementations

## Triggers

Triggers determine when null resources are recreated:

```hcl
triggers = {
  timestamp    = timestamp()           # Always recreate
  file_hash    = filemd5("config.txt") # When file changes
  instance_id  = aws_instance.web.id   # When instance changes
  date         = formatdate("YYYY-MM-DD", timestamp()) # Daily
}
```

## Best Practices

- Use specific triggers to avoid unnecessary recreation
- Include destroy-time provisioners for cleanup
- Handle errors gracefully in scripts
- Use `depends_on` for explicit dependencies
- Keep provisioner scripts idempotent

## Commands

```bash
terraform plan
terraform apply
terraform destroy
```

## Alternatives

- **terraform_data**: Modern replacement (Terraform 1.4+)
- **local-exec**: For simple local commands
- **remote-exec**: For simple remote commands
