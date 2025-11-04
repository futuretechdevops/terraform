# Terraform Locals

Local values assign names to expressions for reuse within a module.

## Use Cases

- **Common Tags**: Standardize resource tagging
- **Naming Conventions**: Consistent resource naming
- **Conditional Logic**: Environment-specific values
- **Complex Calculations**: Avoid repetition
- **String Manipulation**: Transform input values

## Benefits

- **DRY Principle**: Don't repeat yourself
- **Readability**: Named expressions are clearer
- **Maintainability**: Change once, update everywhere
- **Performance**: Expressions evaluated once

## Syntax

```hcl
locals {
  name = expression
}

# Reference with local.name
```

## Best Practices

- Use for computed values, not simple constants
- Group related locals together
- Use descriptive names
- Avoid complex nested expressions
