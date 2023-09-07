data "aws_iam_policy_document" "backup" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backup" {
  name               = "us-unicorn-backup"
  assume_role_policy = data.aws_iam_policy_document.backup.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backup.name
}

resource "aws_backup_vault" "db" {
  name = "us-unicorn-db-backup-vault"
}

resource "aws_backup_plan" "db" {
  name = "us-unicorn-db-backup-plan"

  rule {
    rule_name         = "us-unicorn-db-backup-rule"
    target_vault_name = aws_backup_vault.db.name
    schedule          = "cron(0 12 * * ? *)"

    enable_continuous_backup = true

    lifecycle {
      delete_after = 14
    }
  }
}

resource "aws_backup_selection" "db" {
  name = "us-unicorn-db-backup-selection"
  
  iam_role_arn = aws_iam_role.backup.arn
  plan_id = aws_backup_plan.db.id

  resources = [
    aws_dynamodb_table.db.arn,
    aws_rds_cluster.db.arn
  ]
}
