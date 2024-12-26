data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
locals {
  use_az = [
    "${data.aws_region.current.name}a",
    "${data.aws_region.current.name}b", 
    "${data.aws_region.current.name}c",
  ]
  az_short = [
    "a", "b" ,"c",
  ]
}




/////// VPC ///////


resource "aws_vpc" "vpc" {

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "vpc"
        Environment = var.environment
  }
}



resource "aws_subnet" "public" {
  count             = 3
  availability_zone = local.use_az[count.index]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)

  tags = {
    Name                                        = "public-subnet-${local.az_short[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
        Environment = var.environment
  }
}



resource "aws_subnet" "private" {
  count = 3

  availability_zone = local.use_az[floor(count.index / 2)]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 3)

  tags = {
    Name                                        = "k8s-${local.az_short[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
        Environment = var.environment
  }
}

resource "aws_subnet" "db" {
  count = 3

  availability_zone = local.use_az[floor(count.index / 2)]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 6)

  tags = {
    Name                                        = "db-${local.az_short[count.index]}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
        Environment = var.environment
  }
}



resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
        Environment = var.environment
  }
}


resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[1].id

  tags = {
    Name = "natgw"
        Environment = var.environment
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_eip" "nat_eip" {

  tags = {
    Name = "natgw-eip"
        Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "igw-rt"
        Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "nat-rt"
        Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
  count          = 3
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private.id
}