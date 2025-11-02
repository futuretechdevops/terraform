# Basic VPC and Subnet - Multi File Structure

This example creates the same VPC infrastructure but organized across multiple files for better maintainability.

## File Structure

```
01-basic-vpc-subnet-multi/
├── versions.tf       # Terraform and provider versions
├── provider.tf       # AWS provider configuration
├── variables.tf      # Input variable definitions
├── data.tf          # Data sources
├── main.tf          # VPC and subnet resources
├── routing.tf       # Route tables and associations
├── outputs.tf       # Output values
├── terraform.tfvars # Variable values
└── README.md        # This file
```

## File Purposes

### versions.tf
- Defines required Terraform version
- Specifies provider versions
- Ensures consistency across environments

### provider.tf
- Configures AWS provider
- Uses variables for flexibility

### variables.tf
- Defines all input parameters
- Includes descriptions and defaults
- Makes configuration reusable

### data.tf
- External data sources
- Gets available AZs dynamically

### main.tf
- Core infrastructure resources
- VPC, subnets, internet gateway

### routing.tf
- Network routing configuration
- Route tables and associations

### outputs.tf
- Values to display after apply
- Can be used by other configurations

### terraform.tfvars
- Actual values for variables
- Customize without changing code

## Advantages of Multi-File Structure

1. **Organization**: Logical separation of concerns
2. **Maintainability**: Easier to find and modify specific components
3. **Reusability**: Variables make it flexible
4. **Collaboration**: Team members can work on different files
5. **Scalability**: Easy to add more resources

## Commands

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

## Customization

Edit `terraform.tfvars` to change:
- AWS region
- CIDR blocks
- Project name

## Variable Precedence Order

Terraform processes variables in this priority (highest to lowest):

1. **Command Line `-var` flags** (HIGHEST)
   ```bash
   terraform apply -var="aws_region=us-west-2"
   ```

2. **Command Line `-var-file` flags**
   ```bash
   terraform apply -var-file="prod.tfvars"
   ```

3. **`*.auto.tfvars` files** (alphabetical order)
   ```bash
   a.auto.tfvars    # Processed first
   z.auto.tfvars    # Wins over a.auto.tfvars
   ```

4. **`terraform.tfvars` file**
   ```hcl
   aws_region = "ap-south-1"
   ```

5. **Environment Variables**
   ```bash
   export TF_VAR_aws_region="eu-west-1"
   ```

6. **Variable defaults in `.tf` files** (LOWEST)
   ```hcl
   variable "aws_region" {
     default = "us-east-1"
   }
   ```

## File Processing

- Terraform reads ALL `.tf` files simultaneously
- Execution order determined by **dependencies**, not file names
- Variable definitions must be unique across all `.tf` files
- Use `terraform graph` to see dependency relationships

## What This Creates

Same infrastructure as single-file version:
- Custom VPC with configurable CIDR
- Public subnet with internet access
- Private subnet without internet access
- Internet Gateway and routing
