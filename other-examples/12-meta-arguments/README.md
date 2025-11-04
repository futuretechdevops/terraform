# Terraform Meta-Arguments

Meta-arguments change resource behavior and can be used with any resource type.

## Meta-Arguments

### depends_on
- Explicit dependencies between resources
- Use when implicit dependencies aren't sufficient

### count
- Create multiple instances of a resource
- Access with `count.index`
- Results in list of resources

### for_each
- Create instances based on map or set
- Access with `each.key` and `each.value`
- Results in map of resources

### provider
- Specify which provider configuration to use
- Useful with provider aliases

### lifecycle
- Control resource lifecycle behavior
- `create_before_destroy`, `prevent_destroy`, `ignore_changes`

## Usage Patterns

```bash
terraform plan
terraform apply
terraform state list  # See created resources
```

## Best Practices

- Use `for_each` over `count` when possible
- Be careful with `prevent_destroy`
- Use `ignore_changes` sparingly
