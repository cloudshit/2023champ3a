resource "aws_rds_global_cluster" "global" {
  global_cluster_identifier = "unicorn-db-global"
  engine                    = "aurora-mysql"
  storage_encrypted = true
}
