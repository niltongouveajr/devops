variable "vpc_id" {
  type = string
}

output "igw_id" {
  value = join("", aws_internet_gateway.module-infrastructure-network-igw.*.id)
}
