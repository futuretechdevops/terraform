aws_region         = "ap-south-1"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type      = "t3.micro"
project_name       = "my-webapp"

# Key Pair Options:
# Option 2: Use existing key pair
create_key_pair    = false
key_name           = "futuretechdevops15"  # Remove .pem extension
