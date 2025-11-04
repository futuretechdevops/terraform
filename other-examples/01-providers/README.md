# Terraform Providers

Providers are plugins that interact with APIs of cloud platforms and services.

## Key Concepts

- **Required Providers**: Specify provider sources and versions
- **Provider Configuration**: Set authentication and region
- **Provider Aliases**: Use multiple configurations of same provider
- **Version Constraints**: Control provider versions

## Provider Types

- **Official**: hashicorp/aws, hashicorp/azurerm
- **Partner**: datadog/datadog, mongodb/mongodbatlas  
- **Community**: kreuzwerker/docker

## Usage

```bash
terraform init    # Downloads providers
terraform plan
terraform apply
```

## Best Practices

- Pin provider versions
- Use aliases for multi-region deployments
- Configure authentication via environment variables
