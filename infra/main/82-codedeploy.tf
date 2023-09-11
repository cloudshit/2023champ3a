data "aws_iam_policy_document" "assume_role_deploy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "deploy" {
  name               = "us-skills-role-deploy"
  assume_role_policy = data.aws_iam_policy_document.assume_role_deploy.json
}

data "aws_iam_policy_document" "deploy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:*",
      "s3:*",
      "ecr:*",
      "ecs:*",
      "elasticloadbalancing:*",
      "ec2:*",
      "lambda:*"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "deploy" {
  role   = aws_iam_role.deploy.name
  policy = data.aws_iam_policy_document.deploy.json
}

resource "aws_codedeploy_app" "app" {
  compute_platform = "Server"
  name             = "skills-app"
}

resource "aws_codedeploy_deployment_group" "dg" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "skills-dg"
  service_role_arn       = aws_iam_role.deploy.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "us-unicorn-bastion"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
