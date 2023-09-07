resource "aws_security_group" "buildmachine" {
  name = "us-unicorn-buildmachine-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    security_groups = [
      aws_security_group.bastion.id
    ]
    from_port = "22"
    to_port = "22"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "80"
    to_port = "80"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "443"
    to_port = "443"
  }

  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
}

resource "aws_iam_role" "buildmachine" {
  name = "us-unicorn-role-buildmachine"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

resource "aws_iam_instance_profile" "buildmachine" {
  name = "us-unicorn-profile-buildmachine"
  role = aws_iam_role.buildmachine.name
}

resource "aws_instance" "buildmachine" {
  instance_type = "t4g.small"
  subnet_id = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.buildmachine.id]
  iam_instance_profile = aws_iam_instance_profile.buildmachine.name
  key_name = aws_key_pair.keypair.key_name
  
  ami = "ami-0a27863587713655c"

  tags = {
    Name = "us-unicorn-buildmachine"
  }

  user_data = <<-EOF
    #!/bin/bash
    curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    yum install -y docker git
    usermod -aG docker ec2-user
    systemctl enable --now docker

    git clone https://github.com/cloudshit/2023champ3.git /home/ec2-user/2023champ3
    chown ec2-user:ec2-user -R /home/ec2-user/2023champ3
  EOF
}
