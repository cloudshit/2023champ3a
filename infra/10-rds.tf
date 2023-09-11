resource "aws_rds_global_cluster" "global" {
  global_cluster_identifier = "unicorn-db-global"
  engine                    = "aurora-mysql"
  storage_encrypted = true
}

resource "random_password" "db_pass" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
