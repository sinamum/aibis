terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.56"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.4"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}