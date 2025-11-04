# Terraform Refresh

Update Terraform state to match real-world infrastructure changes.

## Refresh Commands

### Automatic Refresh (Default)
```bash
# Plan automatically refreshes state
terraform plan

# Apply automatically refreshes state
terraform apply
```

### Manual Refresh
```bash
# Refresh state without making changes
terraform refresh

# Refresh-only plan (Terraform 0.15.4+)
terraform plan -refresh-only

# Apply refresh-only changes
terraform apply -refresh-only
```

### Disable Refresh
```bash
# Skip refresh during plan
terraform plan -refresh=false

# Skip refresh during apply
terraform apply -refresh=false
```

## When Refresh is Needed

- **Manual Changes**: Resources modified outside Terraform
- **Drift Detection**: Identify configuration drift
- **State Synchronization**: Sync state with reality
- **Troubleshooting**: Resolve state inconsistencies

## Refresh Process

1. **Query Providers**: Get current resource state
2. **Compare State**: Check against Terraform state
3. **Update State**: Modify state file to match reality
4. **Show Differences**: Display detected changes

## Configuration Drift

### Common Drift Scenarios
- Tags added/removed manually
- Security group rules modified
- Instance types changed
- Storage configurations updated
- IAM policies attached/detached

### Detecting Drift
```bash
# Check for drift
terraform plan -refresh-only

# See what changed
terraform show
```

## Best Practices

- Run refresh regularly in CI/CD
- Use `-refresh-only` to see changes before applying
- Investigate unexpected drift
- Use resource-level `ignore_changes` for expected drift
- Monitor infrastructure changes with CloudTrail

## Refresh vs Import

- **Refresh**: Update existing tracked resources
- **Import**: Add untracked resources to state
