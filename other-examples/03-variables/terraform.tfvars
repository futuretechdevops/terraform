region           = "ap-south-1"
instance_count   = 3
enable_monitoring = true
availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]

instance_types = {
  dev  = "t2.micro"
  prod = "t3.large"
}

database_config = {
  engine         = "postgres"
  engine_version = "13.7"
  instance_class = "db.t3.small"
  allocated_storage = 50
}

db_password = "supersecret123"
