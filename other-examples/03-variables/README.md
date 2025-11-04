# Terraform Variables

Variables make configurations flexible and reusable.

## Variable Types

- **string**: Text values
- **number**: Numeric values  
- **bool**: true/false
- **list**: Ordered collection
- **map**: Key-value pairs
- **object**: Complex structured data

## Variable Sources (precedence order)

1. Command line: `-var="key=value"`
2. `.tfvars` files: `-var-file="file.tfvars"`
3. Environment variables: `TF_VAR_name`
4. Default values in variable blocks

## Features

- **Validation**: Custom validation rules
- **Sensitive**: Hide values in logs
- **Description**: Documentation

## Usage

```bash
terraform plan -var="instance_count=5"
terraform apply -var-file="prod.tfvars"
```
