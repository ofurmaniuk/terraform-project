resource "kubectl_manifest" "argocd_web" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: web-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/ofurmaniuk/terraform-project.git
    path: apps/web
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML

  depends_on = [
    helm_release.argocd,
    helm_release.ingress_nginx,
    kubernetes_namespace.argocd
  ]

  wait = true
  server_side_apply = true
}

resource "kubectl_manifest" "argocd_api" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: api-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/ofurmaniuk/terraform-project.git
    path: apps/api
    targetRevision: main
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML

  depends_on = [
    helm_release.argocd,
    helm_release.ingress_nginx,
    kubernetes_namespace.argocd
  ]

  wait = true
  server_side_apply = true
}