//VPC-AREA
resource "aws_vpc" "fgd3-vpc" {
  cidr_block =  var.vpc_cidr
}

//This for subnet 1
resource "aws_subnet" "subnet-fgd3" {
  vpc_id     = aws_vpc.fgd3-vpc.id
  cidr_block = var.subnet1_cidr
  availability_zone = var.subnet_az
  tags = {
    Name = "subnet-fgd3"
  }
}

//This for IGW
resource "aws_internet_gateway" "igw-fgd3" {
  vpc_id = aws_vpc.fgd3-vpc.id

  tags = {
    Name = "igw-fgd3"
  }
}

//This For Route Table
resource "aws_route_table" "rt-fgd3" {
  vpc_id = aws_vpc.fgd3-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-fgd3.id
  }
  tags = {
    Name = "rt-fgd3"
  }
}

//This for association subnet with route table
resource "aws_route_table_association" "association-rt-fgd3" {
  subnet_id      = aws_subnet.subnet-fgd3.id
  route_table_id = aws_route_table.rt-fgd3.id
}



// CONNCET Subnet 2 to Route Table IGW
resource "aws_route_table_association" "association-rt-fgd3-2" {
  subnet_id      = aws_subnet.subnet-fgd3-2.id
  route_table_id = aws_route_table.rt-fgd3.id
}

// Subnet Private FOR Database IN AZ 1a
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = aws_vpc.fgd3-vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "ap-southeast-1a"
  tags = { Name = "db-subnet-1" }
}

// Subnet Private For  Database IN AZ 1b 
resource "aws_subnet" "db_subnet_2" {
  vpc_id            = aws_vpc.fgd3-vpc.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "ap-southeast-1b"
  tags = { Name = "db-subnet-2" }
}

// Public Subnet 2 IN AZ 1b
resource "aws_subnet" "subnet-fgd3-2" {
  vpc_id            = aws_vpc.fgd3-vpc.id
  cidr_block        = "10.10.20.0/24" 
  availability_zone = "ap-southeast-1b"
  
  tags = { Name = "subnet-fgd3-2-public" }
}

// --- 1. Subnet Private FOR EC2 (App Layer) ---
resource "aws_subnet" "app_subnet_1" {
  vpc_id            = aws_vpc.fgd3-vpc.id
  cidr_block        = "10.10.30.0/24"
  availability_zone = "ap-southeast-1a"
  tags = { Name = "app-subnet-1-private" }
}

// --- Subnet Private 2 FOR EC2 (App Layer) AZ 1b ---
resource "aws_subnet" "app_subnet_2" {
  vpc_id            = aws_vpc.fgd3-vpc.id
  cidr_block        = "10.10.40.0/24" 
  availability_zone = "ap-southeast-1b"
  tags = { Name = "app-subnet-2-private" }
}

// --- Elastic IP FOR NAT Gateway ---
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

// ---  NAT Gateway  ---
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet-fgd3.id 
  tags = { Name = "fgd3-nat-gw" }
  
  depends_on = [aws_internet_gateway.igw-fgd3]
}

// --- Route Table Only Private ---
resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.fgd3-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = { Name = "rt-fgd3-private" }
}

// --- Connecy App Subnet to Route Table Private ---
resource "aws_route_table_association" "assoc_app_rt" {
  subnet_id      = aws_subnet.app_subnet_1.id
  route_table_id = aws_route_table.rt_private.id
}

// --- Connect App Subnet 2 to Route Table Private ---
resource "aws_route_table_association" "assoc_app_rt_2" {
  subnet_id      = aws_subnet.app_subnet_2.id
  route_table_id = aws_route_table.rt_private.id
}

//This For NACL
resource "aws_network_acl" "fgd3-main-nacl" {
  vpc_id     = aws_vpc.fgd3-vpc.id
  subnet_ids = [aws_subnet.subnet-fgd3.id]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }
ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "icmp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
    icmp_type = -1
    icmp_code = -1
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 140
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "fgd3-main-nacl"
  }
}