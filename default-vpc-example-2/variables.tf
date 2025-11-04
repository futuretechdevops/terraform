variable "ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The key pair name to use for the instance"
  type        = string
}

variable "instance_name" {
  description = "Tag name for the EC2 instance"
  type        = string
  default     = "Terraform-EC2-Demo"
}
