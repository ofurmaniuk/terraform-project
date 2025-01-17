resource "time_sleep" "wait_for_kubernetes" {
  depends_on = [var.cluster_endpoint]
  create_duration = "60s"
}

resource "kubernetes_namespace" "argocd" {
  depends_on = [time_sleep.wait_for_kubernetes]
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }
}