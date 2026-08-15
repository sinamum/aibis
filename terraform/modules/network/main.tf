locals {
  tags = merge(var.tags, {
    "Name" = var.name
  })
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  # Ambos obrigatórios para o EKS: os nós resolvem o endpoint do control plane
  # e os endpoints de serviço por nome DNS interno.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    "Name" = "${var.name}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    "Name" = "${var.name}-igw"
  })
}

# ── Subnets públicas ──────────────────────────────────────────────────
# Hospedam o balanceador externo e o gateway de saída. Nenhum nó do cluster
# vive aqui.
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  # O balanceador precisa de endereço público; os nós, não — e eles não ficam aqui.
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    "Name" = "${var.name}-public-${var.azs[count.index]}"
    # Tag de descoberta: sem ela o controlador de serviço do EKS não encontra
    # onde publicar um Service do tipo LoadBalancer externo. A ausência não gera
    # erro em lugar nenhum — o EXTERNAL-IP simplesmente fica pendente para sempre.
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# ── Subnets privadas ──────────────────────────────────────────────────
# Onde os nós do cluster ficam. Alcançam a internet só pela saída controlada.
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  # Explícito, e não confiando no default: é isto que mantém os nós sem
  # endereço alcançável a partir da internet.
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    "Name"                                      = "${var.name}-private-${var.azs[count.index]}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# ── Saída controlada única ────────────────────────────────────────────
# Um gateway só, e não um por zona: em laboratório o custo por hora de cada
# gateway adicional não compra nada.
#
# Consequência não-óbvia: com saída única, TODO o cluster obtém imagens por um
# mesmo endereço de origem — e o limite de consumo do registro público é contado
# por origem. O sintoma de estourar o limite é indistinguível de erro de
# referência de imagem.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(local.tags, {
    "Name" = "${var.name}-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.tags, {
    "Name" = "${var.name}-nat"
  })

  depends_on = [aws_internet_gateway.this]
}

# ── Roteamento ────────────────────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.tags, {
    "Name" = "${var.name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Uma tabela por subnet privada, mesmo com gateway único: se um dia a saída
# passar a ser por zona, muda o destino da rota e não a estrutura.
resource "aws_route_table" "private" {
  count = length(aws_subnet.private)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(local.tags, {
    "Name" = "${var.name}-private-rt-${var.azs[count.index]}"
  })
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}