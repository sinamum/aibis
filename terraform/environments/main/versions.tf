terraform {
  # Terraform CLI mais recente em 2026-07-26: 1.15.8 (api.releases.hashicorp.com).
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 6.56.0 consultado em registry.terraform.io em 2026-07-26 (publicado 2026-07-22).
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

  # Estado local, por decisão do responsável: há um operador só, e um repositório
  # de estado compartilhado seria um passo extra sem benefício aqui.
  #
  # O risco que isso cria e sua mitigação obrigatória: o estado carrega dados
  # sensíveis do cluster em texto claro e este repositório é público. A exclusão
  # no controle de versão (.gitignore) precisa existir ANTES do primeiro `init` —
  # não é higiene, é a única mitigação.
  #
  # Perder o estado também remove a capacidade de destruir pelo código, deixando
  # componentes cobrando indefinidamente.
  backend "local" {
    path = "terraform.tfstate"
  }
}