terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 6.56.0 consultado em registry.terraform.io em 2026-07-26 (publicado 2026-07-22).
      version = "~> 6.56"
    }
  }
}

# Sem bloco `provider` aqui — ver a mesma nota em modules/network/versions.tf.