# AWS Database Resources

## RDS (Relational Database Service)
**Purpose**: Managed relational databases
**Terraform Resource**: `aws_db_instance`
**Use Cases**: MySQL, PostgreSQL, Oracle, SQL Server
**Example**:
```hcl
resource "aws_db_instance" "main" {
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  allocated_storage = 20
}
```

## DynamoDB
**Purpose**: NoSQL database service
**Terraform Resource**: `aws_dynamodb_table`
**Use Cases**: Key-value store, document database
**Example**:
```hcl
resource "aws_dynamodb_table" "users" {
  name           = "users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  attribute {
    name = "id"
    type = "S"
  }
}
```

## ElastiCache
**Purpose**: In-memory caching service
**Terraform Resource**: `aws_elasticache_cluster`
**Use Cases**: Redis, Memcached caching
**Example**:
```hcl
resource "aws_elasticache_cluster" "cache" {
  cluster_id       = "app-cache"
  engine           = "redis"
  node_type        = "cache.t3.micro"
  num_cache_nodes  = 1
}
```

## DocumentDB
**Purpose**: MongoDB-compatible document database
**Terraform Resource**: `aws_docdb_cluster`
**Use Cases**: Document storage, content management
**Example**:
```hcl
resource "aws_docdb_cluster" "docs" {
  cluster_identifier = "my-docdb-cluster"
  engine             = "docdb"
  master_username    = "username"
  master_password    = "password"
}
```

## Neptune
**Purpose**: Graph database service
**Terraform Resource**: `aws_neptune_cluster`
**Use Cases**: Social networks, recommendation engines
**Example**:
```hcl
resource "aws_neptune_cluster" "graph" {
  cluster_identifier = "neptune-cluster"
  engine             = "neptune"
}
```

## Redshift
**Purpose**: Data warehouse service
**Terraform Resource**: `aws_redshift_cluster`
**Use Cases**: Analytics, business intelligence
**Example**:
```hcl
resource "aws_redshift_cluster" "warehouse" {
  cluster_identifier = "data-warehouse"
  database_name      = "analytics"
  master_username    = "admin"
  node_type          = "dc2.large"
}
```
