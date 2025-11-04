# Terraform Resources

Resources are the most important element - they describe infrastructure objects.

## Resource Syntax

```hcl
resource "resource_type" "name" {
  argument = "value"
}
```

## Key Features

- **Dependencies**: Implicit (references) and explicit (depends_on)
- **Lifecycle Rules**: Control resource creation/destruction behavior
- **Timeouts**: Custom timeout values for operations
- **Meta-arguments**: count, for_each, provider, lifecycle

## Lifecycle Rules

- `create_before_destroy`: Create replacement before destroying
- `prevent_destroy`: Prevent accidental deletion
- `ignore_changes`: Ignore changes to specific attributes

## Usage

```bash
terraform plan
terraform apply
terraform destroy
```
