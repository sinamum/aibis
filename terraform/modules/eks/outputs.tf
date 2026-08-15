output "cluster_name" {
  value       = aws_eks_cluster.this.name
  description = "Nome do cluster, para configurar o acesso com `aws eks update-kubeconfig`."
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "Endpoint do servidor de API do cluster."
}

output "cluster_version" {
  value       = aws_eks_cluster.this.version
  description = "Versão de Kubernetes efetivamente provisionada no control plane."
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  description = "Certificado da autoridade do cluster, necessário para autenticar no servidor de API."
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description = "Grupo de segurança criado pelo EKS para a comunicação entre control plane e nós."
}

output "node_group_name" {
  value       = aws_eks_node_group.this.node_group_name
  description = "Nome do grupo de nós gerenciado."
}