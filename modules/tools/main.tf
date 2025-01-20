resource "time_sleep" "wait_for_kubernetes" {
  depends_on = [var.cluster_endpoint]
  create_duration = "60s"
}

resource "kubectl_manifest" "argocd_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
  labels:
    name: argocd
    environment: ${var.environment}
    managed-by: terraform
YAML

  override_namespace = "argocd"
  force_new         = false
  server_side_apply = true

  lifecycle {
    ignore_changes = all
  }
}