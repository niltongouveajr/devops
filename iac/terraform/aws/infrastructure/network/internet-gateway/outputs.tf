variable "vpc_id" {
  description = "" 
  type        = string
}

output "igw_id" {
  description = "" 
  value       = join("", aws_internet_gateway.module-infrastructure-network-igw.*.id)
}
