provider "aws" {
  region = var.region
}

resource "aws_instance" "fgd-3" {
  ami = var.os_name
  key_name = var.key
  instance_type = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet-fgd3.id
  vpc_security_group_ids = [ aws_security_group.fgd3-vpc-sg.id ]
}
 
//VPC-AREA
resource "aws_vpc" "fgd3-vpc" {
  cidr_block =  var.vpc_cidr
}

//This for subnet
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

//This for security group
resource "aws_security_group" "fgd3-vpc-sg" {
  name        = "fgd3-vpc-sg"
  vpc_id      = aws_vpc.fgd3-vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = -1
    to_port          = -1
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "fgd3-vpc-sg"
  }
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