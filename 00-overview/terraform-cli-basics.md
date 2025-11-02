# Terraform CLI Basics

## Essential Commands

### **terraform init**
**Purpose**: Initialize working directory
**When to use**: First time setup, after adding providers/modules
```bash
# Basic initialization
terraform init

# Upgrade providers
terraform init -upgrade

# Reconfigure backend
terraform init -reconfigure

# Copy modules from different source
terraform init -from-module=./modules/vpc
```

### **terraform plan**
**Purpose**: Preview changes before applying
**When to use**: Before every apply, to review changes
```bash
# Basic plan
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Plan with specific variables
terraform plan -var="instance_type=t2.small"

# Plan with variable file
terraform plan -var-file="prod.tfvars"

# Plan for specific target
terraform plan -target=aws_instance.web
```

### **terraform apply**
**Purpose**: Create/update infrastructure
**When to use**: After reviewing plan
```bash
# Apply with confirmation
terraform apply

# Apply without confirmation
terraform apply -auto-approve

# Apply saved plan
terraform apply tfplan

# Apply with variables
terraform apply -var="environment=prod"

# Apply specific target
terraform apply -target=aws_instance.web
```

### **terraform destroy**
**Purpose**: Remove all managed infrastructure
**When to use**: Cleanup, environment teardown
```bash
# Destroy with confirmation
terraform destroy

# Destroy without confirmation
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=aws_instance.web

# Destroy with variables
terraform destroy -var-file="prod.tfvars"
```

## State Management Commands

### **terraform show**
**Purpose**: Display current state or saved plan
```bash
# Show current state
terraform show

# Show saved plan
terraform show tfplan

# Show in JSON format
terraform show -json
```

### **terraform state**
**Purpose**: Advanced state management
```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Move resource to different address
terraform state mv aws_instance.web aws_instance.web_server

# Remove resource from state
terraform state rm aws_instance.web

# Import existing resource
terraform import aws_instance.web i-1234567890abcdef0

# Pull remote state
terraform state pull

# Push state to remote
terraform state push terraform.tfstate
```

### **terraform refresh**
**Purpose**: Update state with real infrastructure
```bash
# Refresh state
terraform refresh

# Refresh with variables
terraform refresh -var-file="prod.tfvars"
```

## Validation and Formatting

### **terraform validate**
**Purpose**: Check configuration syntax
```bash
# Validate configuration
terraform validate

# Validate with JSON output
terraform validate -json
```

### **terraform fmt**
**Purpose**: Format configuration files
```bash
# Format current directory
terraform fmt

# Format recursively
terraform fmt -recursive

# Check if formatting needed
terraform fmt -check

# Show differences
terraform fmt -diff
```

## Workspace Management

### **terraform workspace**
**Purpose**: Manage multiple environments
```bash
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new development

# Select workspace
terraform workspace select production

# Show current workspace
terraform workspace show

# Delete workspace
terraform workspace delete development
```

## Output and Variables

### **terraform output**
**Purpose**: Display output values
```bash
# Show all outputs
terraform output

# Show specific output
terraform output instance_ip

# Output in JSON format
terraform output -json

# Raw output (no quotes)
terraform output -raw instance_ip
```

### **terraform console**
**Purpose**: Interactive console for expressions
```bash
# Start console
terraform console

# Example console usage
> var.instance_type
"t2.micro"

> aws_instance.web.public_ip
"1.2.3.4"

> length(var.subnet_ids)
3
```

## Advanced Commands

### **terraform graph**
**Purpose**: Generate dependency graph
```bash
# Generate graph
terraform graph

# Generate graph in DOT format
terraform graph | dot -Tpng > graph.png
```

### **terraform taint**
**Purpose**: Mark resource for recreation
```bash
# Taint resource
terraform taint aws_instance.web

# Untaint resource
terraform untaint aws_instance.web
```

### **terraform force-unlock**
**Purpose**: Remove state lock
```bash
# Force unlock (use LOCK_ID from error message)
terraform force-unlock LOCK_ID
```

## Global Options

### Common Flags
```bash
# Change working directory
terraform -chdir=/path/to/config plan

# Disable color output
terraform plan -no-color

# Enable detailed logging
TF_LOG=DEBUG terraform plan

# Set log file
TF_LOG_PATH=terraform.log terraform apply
```

### Environment Variables
```bash
# Set log level
export TF_LOG=INFO

# Set variable values
export TF_VAR_instance_type=t2.small

# Set AWS profile
export AWS_PROFILE=production

# Disable input prompts
export TF_INPUT=false
```

## Command Combinations

### Complete Workflow
```bash
# 1. Initialize
terraform init

# 2. Format code
terraform fmt

# 3. Validate syntax
terraform validate

# 4. Plan changes
terraform plan -out=tfplan

# 5. Apply changes
terraform apply tfplan

# 6. Show results
terraform output
```

### Development Workflow
```bash
# Quick validation
terraform fmt && terraform validate

# Plan and apply in one go (development only)
terraform plan && terraform apply -auto-approve

# Check what changed
terraform plan -detailed-exitcode
```

### Production Workflow
```bash
# Always save and review plans
terraform plan -var-file="prod.tfvars" -out=prod.tfplan

# Review plan file
terraform show prod.tfplan

# Apply only after approval
terraform apply prod.tfplan
```

## Troubleshooting Commands

### Debug Information
```bash
# Enable debug logging
TF_LOG=DEBUG terraform plan

# Crash logs
ls -la crash.log

# Provider logs
TF_LOG_PROVIDER=DEBUG terraform plan
```

### State Issues
```bash
# Backup state before changes
cp terraform.tfstate terraform.tfstate.backup

# Recover from backup
cp terraform.tfstate.backup terraform.tfstate

# Import existing resources
terraform import aws_instance.web i-1234567890abcdef0
```

### Lock Issues
```bash
# Check lock status
terraform state list

# Force unlock if needed
terraform force-unlock LOCK_ID

# Refresh state
terraform refresh
```

## Best Practices

### Command Usage
- **Always run `terraform plan`** before `apply`
- **Use `-out` flag** to save plans in production
- **Run `terraform fmt`** before committing code
- **Use workspaces** for multiple environments
- **Enable logging** for troubleshooting

### Safety Measures
- **Review plans carefully** before applying
- **Use version control** for all configurations
- **Backup state files** before major changes
- **Test in development** before production
- **Use remote state** for team collaboration
