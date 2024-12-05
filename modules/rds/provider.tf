terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 0.14"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 0.14"
    }
  }
}

