# Terraform Provisioners

Provisioners execute scripts on local or remote machines as part of resource creation.

## Types Demonstrated

- **file**: Copy files to remote machine
- **remote-exec**: Run commands on remote machine  
- **local-exec**: Run commands locally

## Usage

```bash
terraform init
terraform apply
```

## Key Points

- Provisioners run during resource creation
- Use SSH connection for remote provisioners
- Should be last resort - prefer user_data when possible
- Can cause resource recreation if they fail
