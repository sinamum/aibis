terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # 6.56.0 consultado em registry.terraform.io em 2026-07-26 (publicado 2026-07-22).
      version = "~> 6.56"
    }
  }
}

# Sem bloco `provider` aqui, por decisão estrutural: o módulo declara de que
# provider precisa, e NUNCA onde provisionar. Região e credencial vivem no root
# do ambiente e são herdadas. Um módulo que configura o próprio provider carrega
# a decisão de conta e região, e deixa de poder ser instanciado duas vezes.