variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  type        = string
}

# Service configuration variable
variable "argocd_server_service" {
  description = "ArgoCD server service configuration"
  type = object({
    type                 = string
    load_balancer_type   = string
    cross_zone_enabled   = bool
    load_balancer_scheme = string
    source_ranges        = list(string)
  })
  default = {
    type                 = "LoadBalancer"
    load_balancer_type   = "nlb"
    cross_zone_enabled   = true
    load_balancer_scheme = "internet-facing"
    source_ranges        = ["0.0.0.0/0"]
  }
}