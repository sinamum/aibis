# Só o que o consumidor precisa para conectar as coisas. Cada output é contrato:
# a partir do momento em que alguém depende dele, removê-lo quebra.

output "vpc_id" {
  value       = aws_vpc.this.id
  description = "Identificador da VPC criada."
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Identificadores das subnets públicas, na ordem das zonas informadas. Destino do balanceador externo."
}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "Identificadores das subnets privadas, na ordem das zonas informadas. É onde os nós do cluster são criados."
}

output "nat_gateway_public_ip" {
  value       = aws_eip.nat.public_ip
  description = "Endereço público da saída controlada. É a origem única de todo tráfego de saída do cluster — relevante quando o limite de consumo do registro de imagens for contado por origem."
}