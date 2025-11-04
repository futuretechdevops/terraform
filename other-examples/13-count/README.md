# Terraform Count

Create multiple instances of a resource using the count meta-argument.

## Count Features

- **count.index**: Zero-based index of current instance
- **Conditional Creation**: Use count with boolean expressions
- **List Access**: Reference resources with `[index]` syntax
- **Splat Expressions**: Use `[*]` to get all instances

## Use Cases

- Multiple similar resources (servers, subnets)
- Conditional resource creation
- Resource scaling based on variables

## Count vs for_each

**Use count when:**
- Creating identical resources
- Number of resources is dynamic
- Order matters

**Use for_each when:**
- Resources have different configurations
- Need to reference by key instead of index
- Removing middle items shouldn't affect others

## Commands

```bash
terraform plan -var="instance_count=5"
terraform apply
terraform state list
```

## Limitations

- Changing count can cause resource recreation
- Removing middle items shifts indexes
