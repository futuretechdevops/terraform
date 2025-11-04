# String variable
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

# Number variable
variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 2
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

# Boolean variable
variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

# List variable
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# Map variable
variable "instance_types" {
  description = "Instance types by environment"
  type        = map(string)
  default = {
    dev  = "t2.micro"
    prod = "t3.medium"
  }
}

# Object variable
variable "database_config" {
  description = "Database configuration"
  type = object({
    engine         = string
    engine_version = string
    instance_class = string
    allocated_storage = number
  })
  default = {
    engine         = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    allocated_storage = 20
  }
}

# Sensitive variable
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
