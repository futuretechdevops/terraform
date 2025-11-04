# Terraform Modules

Modules are reusable Terraform configurations that encapsulate resources.

## Module Structure

```
modules/vpc/
├── main.tf      # Resources
├── variables.tf # Input variables
└── outputs.tf   # Output values
```

## Benefits

- **Reusability**: Use same code across projects
- **Abstraction**: Hide complexity behind simple interface
- **Standardization**: Enforce organizational standards
- **Composition**: Combine modules to build infrastructure

## Usage

```bash
terraform init
terraform apply
```

## Module Sources

- Local: `./modules/vpc`
- Git: `git::https://github.com/user/repo.git`
- Registry: `terraform-aws-modules/vpc/aws`
