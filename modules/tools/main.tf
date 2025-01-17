# In modules/tools/main.tf, add this before the namespace resource:
resource "time_sleep" "wait_for_kubernetes" {
  depends_on = [var.cluster_endpoint]
  create_duration = "30s"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }

  depends_on = [time_sleep.wait_for_kubernetes]
}