output "public_ip_ec2" {
  description = "PUBLIC IP"
  value = aws_instance.fgd-3.public_ip

}
output "private_ip_ec2" {
  description = "PRIVATE IP"
  value = aws_instance.fgd-3.private_ip
}