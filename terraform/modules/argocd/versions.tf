terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }

    kubectl = {
      source = "alekc/kubectl"
    }
  }
}