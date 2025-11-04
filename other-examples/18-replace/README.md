# Terraform Replace

Force replacement of resources without modifying configuration.

## Replace Command

### Basic Usage
```bash
# Replace single resource
terraform apply -replace="aws_instance.web"

# Replace multiple resources
terraform apply -replace="aws_instance.web" -replace="aws_launch_template.app"
```

### With Count/For Each
```bash
# Replace specific instance in count
terraform apply -replace="aws_instance.workers[1]"

# Replace specific instance in for_each
terraform apply -replace='aws_instance.env_instances["dev"]'
```

## Replace vs Taint

### Replace (Modern - Recommended)
- One-time operation
- No state modification
- Safer for automation
- Available in Terraform 0.15.2+

### Taint (Legacy)
- Modifies state file
- Persistent until applied
- Can be forgotten
- Being deprecated

## When to Use Replace

- **Immutable Infrastructure**: Force recreation
- **Security Incidents**: Replace compromised resources
- **Configuration Drift**: Reset to known state
- **Testing**: Validate recreation process
- **Troubleshooting**: Eliminate resource-specific issues

## Workflow

1. **Identify Resource**: Determine what needs replacement
2. **Plan with Replace**: `terraform plan -replace="resource"`
3. **Review Changes**: Verify replacement plan
4. **Apply**: Execute replacement

## Best Practices

- Always run `terraform plan -replace` first
- Consider dependencies and downstream effects
- Use in CI/CD for immutable deployments
- Document replacement reasons
- Test replacement procedures
