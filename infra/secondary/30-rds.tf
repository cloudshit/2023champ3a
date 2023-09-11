resource "aws_security_group" "db" {
  name        = "ap-unicorn-sg-db"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.main.id

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}

resource "aws_db_subnet_group" "db" {
  name = "ap-unicorn-db-subnets"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id
  ]
}

resource "aws_rds_cluster_parameter_group" "pg" {
  name   = "ap-unicorn-pg"
  family = "aurora-mysql8.0"

  parameter {
    name  = "binlog_format"    
    value = "MIXED"
    apply_method = "pending-reboot"
  }

  parameter {
    name = "log_bin_trust_function_creators"
    value = 1
    apply_method = "pending-reboot"
  }
}

resource "aws_rds_cluster" "db" {
  apply_immediately = true
  cluster_identifier          = "ap-unicorn-mysql-cluster"
  availability_zones        = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  db_subnet_group_name = aws_db_subnet_group.db.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.pg.name
  global_cluster_identifier = var.global_cluster_id
  enable_global_write_forwarding = true
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot = true
  storage_encrypted = true
  kms_key_id = aws_kms_replica_key.db.arn
  engine = "aurora-mysql"
}

resource "aws_rds_cluster_instance" "db" {
  count = 3
  cluster_identifier = aws_rds_cluster.db.id
  instance_class         = "db.r6g.large"
  identifier             = "ap-unicorn-db-${count.index}"
  engine = "aurora-mysql"
}

resource "aws_secretsmanager_secret" "db" {
  name_prefix = "unicorn/dbcred"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    "username" = aws_rds_cluster.db.master_username
    "password" = var.db_password
    "engine" =  "mysql"
    "host" = aws_rds_cluster.db.endpoint
    "port" = aws_rds_cluster.db.port
    "dbClusterIdentifier" = aws_rds_cluster.db.cluster_identifier
    "dbname" = aws_rds_cluster.db.database_name
  })
}

resource "aws_kms_replica_key" "db" {
  description             = "Multi-Region replica key"
  deletion_window_in_days = 7
  primary_key_arn         = var.primary_db_kms
}
