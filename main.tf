module "networking" {
  source       = "./modules/networking"
  vpc_cidr     = var.vpc_cidr
  subnet1_cidr = var.subnet1_cidr
  subnet_az    = var.subnet_az
}

module "compute" {
  source        = "./modules/compute"
  os_name       = var.os_name
  key           = var.key
  instance_type = var.instance_type
  
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  app_subnet_id     = module.networking.app_subnet_id
  db_endpoint       = module.database.db_endpoint
}

// Subnet Private untuk Database di AZ 1a
resource "aws_subnet" "db_subnet_1" {
  vpc_id            = module.networking.vpc_id
  cidr_block        = "10.10.10.0/24"
  availability_zone = "ap-southeast-1a"
  tags = { Name = "db-subnet-1" }
}

// Subnet Private untuk Database di AZ 1b
resource "aws_subnet" "db_subnet_2" {
  vpc_id            = module.networking.vpc_id
  cidr_block        = "10.10.11.0/24"
  availability_zone = "ap-southeast-1b"
  tags = { Name = "db-subnet-2" }
}

module "database" {
  source        = "./modules/database"
  vpc_id        = module.networking.vpc_id
  vpc_cidr      = var.vpc_cidr
  db_subnet_ids = module.networking.db_subnet_ids
}

