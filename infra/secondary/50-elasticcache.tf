resource "aws_security_group" "redis" {
  name        = "ap-unicorn-sg-redis"
  description = "Allow redis traffic"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "ap-unicorn-redis-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id
  ]
}

resource "aws_elasticache_replication_group" "redis" {
  description = "ap-unicorn-redis-cluster"
  replication_group_id       = "ap-unicorn-redis-cluster"

  port                       = 6379
  apply_immediately = true

  multi_az_enabled = true
  automatic_failover_enabled = true

  replicas_per_node_group = 2

  global_replication_group_id = var.global_replication_group_id

  subnet_group_name = aws_elasticache_subnet_group.redis.name
  security_group_ids = [
    aws_security_group.redis.id
  ]
}
