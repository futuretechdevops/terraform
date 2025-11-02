# Complete EC2 Web Application Infrastructure

This example creates a complete infrastructure stack with a Python web application running on EC2.

## File Structure

```
02-complete-ec2-webapp/
├── versions.tf       # Terraform and provider versions
├── provider.tf       # AWS provider configuration
├── variables.tf      # Input variable definitions
├── main.tf          # Infrastructure resources
├── outputs.tf       # Output values
├── terraform.tfvars # Variable values
└── README.md        # This file
```

## What This Creates

### Infrastructure Components
- **VPC**: Custom VPC (10.0.0.0/16)
- **Internet Gateway**: For internet connectivity
- **Public Subnet**: 10.0.1.0/24 in ap-south-1a
- **Route Table**: Routes traffic to internet gateway
- **Security Group**: Allows HTTP (80), Python app (8000), and SSH (22)
- **EC2 Instance**: t2.micro with Amazon Linux 2
- **Key Pair**: For SSH access

### Application
- **Python Web Server**: Runs on port 8000
- **Colorful Webpage**: Animated gradient background
- **Instance Metadata**: Displays EC2 instance information
- **Auto-Start Service**: Application starts automatically on boot

## Prerequisites

### 1. AWS Credentials
Configure AWS credentials (see previous examples for setup)

### 2. Key Pair Setup

**Option A: Create New Key Pair (Recommended for beginners)**
```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa

# Use default terraform.tfvars settings
create_key_pair = true
public_key_path = "~/.ssh/id_rsa.pub"
```

**Option B: Use Existing AWS Key Pair**
```bash
# In terraform.tfvars, change to:
create_key_pair = false
key_name        = "your-existing-key-name"
```

### 3. AMI Handling
- **Automatic**: Uses latest Amazon Linux 2 AMI (recommended)
- **Dynamic**: Always gets the most recent AMI ID
- **Region-aware**: Works in any AWS region

## Key Pair Best Practices

### ✅ Good Approaches:
1. **Dynamic AMI lookup** (current implementation)
2. **Conditional key pair creation**
3. **Parameterized public key path**

### ❌ Avoid:
1. Hardcoded AMI IDs (become outdated)
2. Assuming SSH keys exist at fixed paths
3. Creating key pairs without checking if they exist

## Commands to Run

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Access your web application
# Use the web_url output from terraform apply
```

## After Deployment

### Access the Web Application
1. Note the `web_url` output from `terraform apply`
2. Open browser and go to: `http://PUBLIC_IP:8000`
3. You should see a colorful animated webpage

### SSH to Instance
```bash
# Use the ssh_command output from terraform apply
ssh -i ~/.ssh/id_rsa ec2-user@PUBLIC_IP
```

### Check Application Status
```bash
# SSH to instance and check service
sudo systemctl status webapp.service

# View application logs
cat /home/ec2-user/app.log
```

## Security Groups

- **Port 22**: SSH access from anywhere
- **Port 80**: HTTP access (for future use)
- **Port 8000**: Python application access
- **All Outbound**: Required for package installation

## Troubleshooting

### Web Application Not Accessible
1. Check security group allows port 8000
2. Verify instance is running: `terraform show`
3. SSH to instance and check service: `sudo systemctl status webapp.service`
4. Check application logs: `cat /home/ec2-user/app.log`

### SSH Connection Issues
1. Verify key pair exists: `ls ~/.ssh/id_rsa*`
2. Check security group allows port 22
3. Ensure correct username: `ec2-user` for Amazon Linux

## Cost Considerations

- **t2.micro**: Free tier eligible (750 hours/month)
- **VPC, Subnets, IGW**: Free
- **Data Transfer**: Minimal for testing

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

## What You'll Learn

- Complete infrastructure provisioning
- Security group configuration
- User data scripts for application deployment
- EC2 instance metadata usage
- Systemd service creation
- Network routing and internet connectivity

## Next Steps

- Modify the Python application
- Add load balancer for high availability
- Implement auto-scaling
- Add RDS database
- Use Application Load Balancer
