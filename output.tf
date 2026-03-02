# output "public_ip_ec2" {
#   value = module.compute.public_ip_ec2
# }

# output "private_ip_ec2" {
#   value = module.compute.private_ip_ec2
# }

output "website_url" {
  value = "http://${module.compute.alb_dns_name}"
}