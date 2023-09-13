resource "aws_codecommit_repository" "code" {
  repository_name = "stress-api"
  default_branch = "main"
  lifecycle {
    ignore_changes = [ 
      default_branch
    ]
  }
}

output "codecommit_repository" {
  value = aws_codecommit_repository.code.id
}
