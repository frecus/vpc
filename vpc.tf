provider "aws" {
  region = "eu-west-1"
}

# virtual private cloud 
resource "aws_vpc" "test-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "test-VPC"
  }
}

# setup gateway
resource "aws_internet_gateway" "test-gw" {
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "test-internet-gateway"
  }
}

# public subnet
resource "aws_subnet" "test-public_subnet" {
  depends_on = [
    aws_vpc.test-vpc,
  ]
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = var.subnets_cidr[1]
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
}

# private subnet
resource "aws_subnet" "test-private_subnet" {
  depends_on = [
    aws_vpc.test-vpc,
  ]
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = var.subnets_cidr[0]
  availability_zone = "eu-west-1a"
}

########### setup NAT GW & IGW 
resource "aws_eip" "test-natgw" {
  vpc = true
  tags = {
    "Name" = "test-NatGateway"
  }
}
# put natgw in the public subnet and get eip for it
resource "aws_nat_gateway" "test-natgw" {
  allocation_id = aws_eip.test-natgw.id
  subnet_id     = aws_subnet.test-public_subnet.id
  tags = {
    "Name" = "test-NatGateway"
  }
}

output "test-natgw_ip" {
  value = aws_eip.test-natgw.public_ip
}

resource "aws_route_table" "test-NAT-route-table" {

  vpc_id = aws_vpc.test-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.test-natgw.id
  }
  tags = {
    Name = "test-NAT-route-table"
  }
}

resource "aws_route_table_association" "test-subnet-association" {
  subnet_id      = aws_subnet.test-private_subnet.id
  route_table_id = aws_route_table.test-NAT-route-table.id
}

resource "aws_route_table" "test-IGW-route-table" {

  vpc_id = aws_vpc.test-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test-gw.id
  }
  tags = {
    Name = "test-IGW-route-table"
  }
}
resource "aws_route_table_association" "test-subnet-association-out" {
  subnet_id      = aws_subnet.test-public_subnet.id
  route_table_id = aws_route_table.test-IGW-route-table.id
}


########### end setup GATEWAYS


# security groups setup
resource "aws_security_group" "test-ingress-bastion" {
  name   = "test-bastion-security-group"
  vpc_id = aws_vpc.test-vpc.id
  tags = {
    Name = "test-bastion-sg"
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

