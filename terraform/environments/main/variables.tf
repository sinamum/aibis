variable "region" {
  type        = string
  description = "Região da AWS onde o ambiente é provisionado."
}

variable "environment" {
  type        = string
  description = "Nome do ambiente. Entra no nome dos recursos e nas tags."
}

variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS deste ambiente."
}

variable "cluster_version" {
  type        = string
  description = "Versão menor do Kubernetes do control plane."
}

variable "vpc_cidr" {
  type        = string
  description = "Bloco CIDR da VPC deste ambiente."
}

variable "azs" {
  type        = list(string)
  description = "Zonas de disponibilidade usadas por este ambiente."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs das subnets públicas, um por zona."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs das subnets privadas, um por zona."
}

variable "node_instance_types" {
  type        = list(string)
  description = "Tipos de instância do grupo de nós."
}

variable "node_desired_size" {
  type        = number
  description = "Quantidade de nós mantida em operação."
}

variable "node_min_size" {
  type        = number
  description = "Limite inferior do grupo de nós."
}

variable "node_max_size" {
  type        = number
  description = "Limite superior do grupo de nós."
}