resource "helm_release" "this" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  namespace        = var.namespace
  create_namespace = true

  timeout = 1200

  values = [
    file(var.values_file)
  ]
}

resource "kubectl_manifest" "bootstrap" {
  for_each = var.bootstrap_manifests

  yaml_body = file(each.value)

  depends_on = [
    helm_release.this
  ]
}