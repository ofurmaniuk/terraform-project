resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.46.7"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    file("${path.module}/values/argocd-values.yaml")
  ]

  depends_on = [
    helm_release.ingress_nginx,
    kubernetes_namespace.argocd
  ]
  wait         = true
  wait_for_jobs = true
  timeout      = 600
}
