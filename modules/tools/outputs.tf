output "argocd_url" {
  description = "ArgoCD Server URL"
  value       = "https://${helm_release.argocd.name}-server"
}

output "prometheus_url" {
  description = "Prometheus Server URL"
  value       = "http://${helm_release.prometheus.name}-server"
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}