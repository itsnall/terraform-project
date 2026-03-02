# Security Group FOR RDS 
resource "aws_security_group" "rds_sg" {
  name   = "fgd3-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] 
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "fgd3-db-subnet-group"
  subnet_ids = var.db_subnet_ids
}

# Instance RDS (MySQL)
resource "aws_db_instance" "main" {
  identifier             = "fgd3-db"
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "fgd3database"
  username               = "admin"
  password               = "Admin123" 
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false 
  skip_final_snapshot    = true
}