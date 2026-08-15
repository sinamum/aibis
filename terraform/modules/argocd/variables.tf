variable "namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "values_file" {
  description = "Path to the Argo CD Helm values file"
  type        = string
}

variable "bootstrap_manifests" {
  description = "Map of manifests applied after Argo CD installation"
  type        = map(string)
  default     = {}
}