# Definição do ambiente `dev`.
#
# Só chamadas de capacidade e leituras — nenhuma declaração de recurso solta.
# Se um `resource` aparecer neste arquivo, ou aquilo vira módulo, ou é sinal de
# que o módulo certo ainda não existe.

locals {
  name = "${var.cluster_name}-${var.environment}"

  tags = {
    Project     = "kube-news"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Leitura de algo que já existe fora do Terraform — legítimo no root do ambiente.
data "aws_caller_identity" "current" {}

module "network" {
  source = "../../modules/network"

  name                 = local.name
  cluster_name         = var.cluster_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # O control plane cria interfaces nas duas famílias de subnet; os nós, apenas
  # nas privadas. A separação destes dois inputs é o que impede que um nó nasça
  # com endereço público por descuido de configuração.
  control_plane_subnet_ids = concat(
    module.network.public_subnet_ids,
    module.network.private_subnet_ids,
  )
  node_subnet_ids = module.network.private_subnet_ids

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size

  tags = local.tags
}

module "argocd" {
  source = "../../modules/argocd"

  providers = {
    helm    = helm
    kubectl = kubectl
  }

  namespace = "argocd"

  values_file = "${path.module}/argocd/values.yaml"

  bootstrap_manifests = {
    favorite-go = "${path.module}/argocd/favorite-go-main.yaml"
  }

  depends_on = [
    module.eks
  ]
}