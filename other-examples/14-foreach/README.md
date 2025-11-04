# Terraform for_each

Create multiple instances of a resource using maps or sets with for_each.

## for_each Features

- **each.key**: Key of current item
- **each.value**: Value of current item  
- **Map Results**: Resources accessible by key
- **Conditional Creation**: Filter with for expressions

## Supported Types

- **Set of strings**: `toset(["a", "b", "c"])`
- **Map**: `{key1 = "value1", key2 = "value2"}`

## Advanced Patterns

### Conditional for_each
```hcl
for_each = {
  for k, v in var.config : k => v
  if v.enabled
}
```

### Transform Lists to Sets
```hcl
for_each = toset(var.list_variable)
```

## for_each vs count

**Use for_each when:**
- Resources have different configurations
- Need stable resource addresses
- Removing items shouldn't affect others

**Use count when:**
- Creating identical resources
- Simple numeric scaling

## Commands

```bash
terraform plan
terraform apply
terraform state list
```
