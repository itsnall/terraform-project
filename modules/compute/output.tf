# output "public_ip_ec2" {
#   description = "Public IP dari EC2"
#   value       = aws_instance.fgd-3.public_ip
# }

# output "private_ip_ec2" {
#   description = "Private IP dari EC2"
#   value       = aws_instance.fgd-3.private_ip
# }

output "alb_dns_name" {
  value = aws_lb.fgd3_alb.dns_name
}

