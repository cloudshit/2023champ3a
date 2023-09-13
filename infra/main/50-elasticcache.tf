resource "aws_security_group" "redis" {
  name        = "us-unicorn-sg-redis"
  description = "Allow redis traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    security_groups = [
      aws_security_group.redisrecv.id
    ]
    from_port = "6379"
    to_port = "6379"
  }

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}

resource "aws_security_group" "redisrecv" {
  name        = "us-unicorn-sg-redisrecv"
  description = "Allow redis traffic"
  vpc_id      = aws_vpc.main.id
  
  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "6379"
    to_port = "6379"
  }
  
  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "us-unicorn-redis-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id
  ]
}

resource "aws_elasticache_replication_group" "redis" {
  description = "us-unicorn-redis-cluster"
  replication_group_id       = "us-unicorn-redis-cluster"
  node_type                  = "cache.m6g.large"
  engine_version = "7.0"
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  port                       = 6379
  parameter_group_name       = "default.redis7.cluster.on"
  apply_immediately = true

  multi_az_enabled = true
  automatic_failover_enabled = true

  num_node_groups         = 3
  replicas_per_node_group = 2

  subnet_group_name = aws_elasticache_subnet_group.redis.name
  security_group_ids = [
    aws_security_group.redis.id
  ]
}

output "aws_elasticache_replication_group_id" {
  value = aws_elasticache_replication_group.redis.id
}
