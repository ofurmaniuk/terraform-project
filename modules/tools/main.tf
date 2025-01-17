resource "time_sleep" "wait_for_eks" {
  create_duration = "90s"
  triggers = {
    cluster_endpoint = var.cluster_endpoint
  }
}

resource "kubernetes_namespace" "argocd" {
  depends_on = [time_sleep.wait_for_eks]
  metadata {
    name = "argocd"
    labels = {
      name        = "argocd"
      environment = var.environment
      managed-by  = "terraform"
    }
  }
}

resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace.argocd]
  
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }
}

resource "helm_release" "ingress_nginx" {
  depends_on = [helm_release.argocd]
  
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.7.1"
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
}

resource "helm_release" "metrics_server" {
  depends_on = [helm_release.argocd]
  
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.11.0"
  namespace  = "kube-system"

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
}