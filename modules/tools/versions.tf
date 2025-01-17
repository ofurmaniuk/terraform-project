terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.23.0"
      configuration_aliases = [ kubernetes ]
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.11.0"
      configuration_aliases = [ helm ]
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "~> 1.14.0"
      configuration_aliases = [ kubectl ]
    }
    time = {
      source = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}