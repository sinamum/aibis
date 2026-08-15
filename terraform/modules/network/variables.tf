variable "name" {
  type        = string
  description = "Prefixo de nome aplicado a todos os recursos de rede criados por este módulo."
}

variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS que consumirá esta rede. Usado nas tags de descoberta das subnets — sem elas o controlador de serviço não encontra onde publicar o balanceador."
}

variable "vpc_cidr" {
  type        = string
  description = "Bloco CIDR da VPC. Precisa comportar todas as subnets públicas e privadas."
}

variable "azs" {
  type        = list(string)
  description = "Zonas de disponibilidade onde as subnets serão distribuídas. O EKS exige no mínimo duas."

  validation {
    condition     = length(var.azs) >= 2
    error_message = "O EKS exige subnets em pelo menos duas zonas de disponibilidade."
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs das subnets públicas, um por zona, na mesma ordem de `azs`. Recebem o balanceador externo e o gateway de saída."

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "É preciso ao menos uma subnet pública por zona, com o mínimo de duas zonas."
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs das subnets privadas, um por zona, na mesma ordem de `azs`. É onde os nós do cluster ficam — sem endereço público."

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "É preciso ao menos uma subnet privada por zona, com o mínimo de duas zonas."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags aplicadas a todos os recursos criados pelo módulo."
  default     = {}
}