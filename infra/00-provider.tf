terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }

    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }

    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }


    http = {
      source = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

provider "aws" {
  alias = "main"
  region = "us-east-1"
  profile = "default"
}

provider "aws" {
  alias = "secondary"
  region = "ap-northeast-2"
  profile = "default"
}

provider "tls" {
}

provider "local" {
}

provider "random" {
}

provider "http" {
}

module "main" {
  source = "./main"
  global_cluster_id = aws_rds_global_cluster.global.id
  providers = {
    aws = aws.main
    tls = tls
    local = local
    random = random
    http = http
  }
}

module "secondary" {
  source = "./secondary"
  global_cluster_id = aws_rds_global_cluster.global.id
  global_replication_group_id = aws_elasticache_global_replication_group.global.id
  providers = {
    aws = aws.secondary
    tls = tls
    local = local
    random = random
    http = http
  }
}
