variable "region" {
  default = "ap-southeast-1"

}
variable "os_name" {
  default = "ami-039a8ebebdd2a1def" 

}
variable "key" {
  default = "kyc-01"

}
variable "instance_type" {
  default = "c7i-flex.large"

}
variable "vpc_cidr" {
  default = "10.10.0.0/16"

}
variable "subnet1_cidr" {
  default = "10.10.1.0/24"

}
variable "subnet_az" {
  default = "ap-southeast-1a"
}