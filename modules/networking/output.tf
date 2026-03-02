output "vpc_id" {
  value = aws_vpc.fgd3-vpc.id
}

# output "subnet_id" {
#   value = aws_subnet.subnet-fgd3.id
# }

output "db_subnet_ids" {
  value = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]
}

output "public_subnet_ids" {
  value = [aws_subnet.subnet-fgd3.id, aws_subnet.subnet-fgd3-2.id]
}

output "app_subnet_id" {
  value = aws_subnet.app_subnet_1.id
}

output "app_subnet_id_2" {
  value = aws_subnet.app_subnet_2.id
}