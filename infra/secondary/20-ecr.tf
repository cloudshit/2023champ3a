resource "aws_ecr_repository" "ecr" {
  for_each = toset(["unicorn", "token", "location", "status", "stress"])
  name = each.key
  force_delete = true
}
