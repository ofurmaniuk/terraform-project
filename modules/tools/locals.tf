locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "tools"
    Owner       = "devops-team"
  }

  argocd_values = {
    server = {
      service = {
        type = "LoadBalancer"
      }
      ingress = {
        enabled = true
      }
    }
    dex = {
      enabled = false
    }
  }

  prometheus_values = {
    alertmanager = {
      persistentVolume = {
        enabled = true
        size = "10Gi"
      }
    }
    server = {
      persistentVolume = {
        enabled = true
        size = "50Gi"
      }
    }
  }
}