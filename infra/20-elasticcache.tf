resource "aws_elasticache_global_replication_group" "global" {
  provider = aws.main
  global_replication_group_id_suffix = "unicorn"
  primary_replication_group_id       = module.main.aws_elasticache_replication_group_id
}
