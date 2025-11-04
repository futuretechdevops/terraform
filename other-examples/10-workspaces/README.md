# Terraform Workspaces

Workspaces allow multiple state files for the same configuration.

## Workspace Commands

```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch workspace
terraform workspace select dev

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete dev
```

## Use Cases

- **Environment Separation**: dev, staging, prod
- **Feature Branches**: Temporary environments
- **Multi-tenancy**: Customer-specific deployments
- **Testing**: Isolated test environments

## Workspace Variables

- `terraform.workspace`: Current workspace name
- Use in conditionals and naming

## Best Practices

- Use workspace-specific variable files
- Include workspace in resource names
- Separate sensitive workspaces with different backends
- Document workspace purposes
