provider "aws" {
  alias  = "east"
  region = "sa-east-1"
}


resource "aws_elasticache_cluster" "redis-cluster" {
  cluster_id           = "redis-cluster"
  replication_group_id = aws_elasticache_replication_group.redis-group.id

}

resource "aws_elasticache_replication_group" "redis-group" {
  automatic_failover_enabled  = true
  subnet_group_name           = aws_elasticache_subnet_group.redis_subnet_group.name
  replication_group_id        = "tf-rep-group-1"
  description                 = "Descricao redis replica"
  engine                      = "redis"
  node_type                   = "cache.t3.small"
  num_cache_clusters          = 2
  port                        = 6379
  auth_token                  = aws_secretsmanager_secret.redis-password-new.arn
  transit_encryption_enabled  = true
}

resource "aws_secretsmanager_secret" "redis-password-new" {
  name = "redis-elasticache-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "redis-password-version-new" {
  secret_id     = aws_secretsmanager_secret.redis-password-new.id
  secret_string = jsonencode({"password": "${data.aws_secretsmanager_random_password.password.random_password}"})
}

data "aws_secretsmanager_random_password" "password" {
  password_length     = 128
  exclude_numbers     = true
  exclude_punctuation = true
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = ["subnet-c4046b9f", "subnet-f198ffb8"]
}        

