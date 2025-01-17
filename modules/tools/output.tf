output "argocd_url" {
  description = "ArgoCD Server URL"
  value       = "https://${helm_release.argocd.name}-server"
}


