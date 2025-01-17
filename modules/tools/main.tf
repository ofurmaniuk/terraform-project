resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }

  timeouts {
    delete = "15m"
  }

  depends_on = [var.cluster_endpoint, var.cluster_ca_certificate]
}