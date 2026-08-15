variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS. Precisa coincidir com o informado ao módulo de rede, porque as tags de descoberta das subnets são derivadas dele."
}

variable "cluster_version" {
  type        = string
  description = "Versão menor do Kubernetes do control plane. Deve estar dentro do suporte padrão da AWS no momento da escrita — 1.36 em 2026-07-26."
}

variable "control_plane_subnet_ids" {
  type        = list(string)
  description = "Subnets onde o control plane cria suas interfaces de rede. Precisa cobrir ao menos duas zonas; recebe públicas e privadas."
}

variable "node_subnet_ids" {
  type        = list(string)
  description = "Subnets onde os nós são criados. Devem ser exclusivamente as privadas — é isto que mantém os nós sem endereço público."
}

variable "node_instance_types" {
  type        = list(string)
  description = "Tipos de instância do grupo de nós gerenciado."
}

variable "node_desired_size" {
  type        = number
  description = "Quantidade de nós que o grupo mantém em operação."
}

variable "node_min_size" {
  type        = number
  description = "Limite inferior do grupo de nós."
}

variable "node_max_size" {
  type        = number
  description = "Limite superior do grupo de nós."
}

variable "node_disk_size" {
  type        = number
  description = "Tamanho em GiB do disco de cada nó."
  default     = 20
}

variable "endpoint_public_access" {
  type        = bool
  description = "Se o endpoint do control plane aceita acesso a partir da internet. Necessário para operar o cluster de fora da VPC; não expõe os nós."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags aplicadas a todos os recursos criados pelo módulo."
  default     = {}
}