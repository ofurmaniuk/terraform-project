terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 0.14"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 0.14"
    }
  }
}