resource "aws_security_group" "db" {
  name        = "us-unicorn-sg-db"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    security_groups = [
      aws_security_group.dbrecv.id
    ]
    from_port = "3306"
    to_port = "3306"
  }


  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}

resource "aws_security_group" "dbrecv" {
  name        = "us-unicorn-sg-dbrecv"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.main.id
  
  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "3306"
    to_port = "3306"
  }
  
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
  apply_immediately = true
  cluster_identifier          = "us-unicorn-mysql-cluster"
  availability_zones        = ["us-east-1a", "us-east-1b", "us-east-1c"]
  db_subnet_group_name = aws_db_subnet_group.db.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.pg.name
  global_cluster_identifier = var.global_cluster_id
  master_username             = "unicorn"
  master_password = var.db_password
  vpc_security_group_ids = [aws_security_group.db.id]
  kms_key_id = aws_kms_key.db.arn
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
    "password" = var.db_password
    "engine" =  "mysql"
    "host" = aws_rds_cluster.db.endpoint
    "port" = aws_rds_cluster.db.port
    "dbClusterIdentifier" = aws_rds_cluster.db.cluster_identifier
    "dbname" = aws_rds_cluster.db.database_name
  })
}

resource "aws_kms_key" "db" {
  description             = "Multi-Region primary key"
  deletion_window_in_days = 7
  multi_region            = true
}

output "primary_db_kms" {
  value = aws_kms_key.db.arn
}
