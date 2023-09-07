resource "aws_security_group" "db" {
  name        = "us-unicorn-sg-db"
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
  name = "us-unicorn-db-subnets"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id,
    aws_subnet.private_c.id
  ]
}

resource "random_password" "db_pass" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


resource "aws_rds_cluster_parameter_group" "pg" {
  name   = "us-unicorn-pg"
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
  cluster_identifier          = "us-unicorn-mysql-cluster"
  availability_zones        = ["us-east-1a", "us-east-1b", "us-east-1c"]
  db_subnet_group_name = aws_db_subnet_group.db.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.pg.name
  global_cluster_identifier = var.global_cluster_id
  master_username             = "unicorn"
  master_password = random_password.db_pass.result
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot = true
  storage_encrypted = true
  engine = "aurora-mysql"
}

resource "aws_rds_cluster_instance" "db" {
  count = 3
  cluster_identifier = aws_rds_cluster.db.id
  instance_class         = "db.r6g.large"
  identifier             = "us-unicorn-db-${count.index}"
  engine = "aurora-mysql"
}

resource "aws_secretsmanager_secret" "db" {
  name_prefix = "unicorn/dbcred"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    "username" = aws_rds_cluster.db.master_username
    "password" = random_password.db_pass.result
    "engine" =  "mysql"
    "host" = aws_rds_cluster.db.endpoint
    "port" = aws_rds_cluster.db.port
    "dbClusterIdentifier" = aws_rds_cluster.db.cluster_identifier
    "dbname" = aws_rds_cluster.db.database_name
  })
}

output db_password {
  value = random_password.db_pass.result
}
