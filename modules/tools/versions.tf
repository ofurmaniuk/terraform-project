terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
      configuration_aliases = [helm]
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
      configuration_aliases = [kubernetes]
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
      configuration_aliases = [kubectl]
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}