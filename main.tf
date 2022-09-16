terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
}

provider "aws" {
  alias  = "east" 
  region = "sa-east-1"
}


resource "aws_elasticache_cluster" "redis-cluster" {
  cluster_id           = "redis-cluster"
  engine               = "redis"
  node_type            = "cache.t3.small"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "6.2"
  port                 = 6379
  
}

resource "aws_elasticache_replication_group" "redis-replica" {
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = ["sa-east"]
  replication_group_id        = "tf-rep-group-1"
  description                 = "Descricao redis replica"
  node_type                   = "cache.t3.small"
  num_cache_clusters          = 1
  parameter_group_name        = "default.redis3.2"
  port                        = 6379
  auth_token                  = aws_secretsmanager_secret.redis-password.name
}

resource "aws_secretsmanager_secret" "redis-password" {
  name = data.aws_secretsmanager_random_password.password.random_password
}

data "aws_secretsmanager_random_password" "password" {
  password_length = 128
  exclude_numbers = true
  exclude_punctuation = true
}
