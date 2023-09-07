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

data "aws_caller_identity" "caller" {
}

data "http" "myip" {
  url = "https://myip.wtf/text"
}

variable global_cluster_id {}
