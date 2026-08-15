output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "Conta AWS em que este ambiente está provisionado."
}

output "cluster_name" {
  value       = module.eks.cluster_name
  description = "Nome do cluster, para `aws eks update-kubeconfig --name <valor> --region <região>`."
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "Endpoint do servidor de API do cluster."
}

output "cluster_version" {
  value       = module.eks.cluster_version
  description = "Versão de Kubernetes efetivamente provisionada."
}

output "private_subnet_ids" {
  value       = module.network.private_subnet_ids
  description = "Subnets privadas — onde os nós vivem."
}

output "public_subnet_ids" {
  value       = module.network.public_subnet_ids
  description = "Subnets públicas — destino do balanceador externo."
}

output "nat_gateway_public_ip" {
  value       = module.network.nat_gateway_public_ip
  description = "Origem única de saída do cluster. Relevante quando o limite de consumo do registro de imagens for contado por origem."
}