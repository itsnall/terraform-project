variable "os_name" {}
variable "key" {}
variable "instance_type" {}
variable "vpc_id" {}
# variable "subnet_id" {}
variable "public_subnet_ids" { type = list(string) }
variable "app_subnet_id" { type = string }
variable "app_subnet_id_2" { type = string }
variable "db_endpoint" { type = string }