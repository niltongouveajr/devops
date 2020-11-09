variable "vpc_id" {
  description = "" 
  type        = string
}

variable "igw_id" {
  description = "" 
  type        = string
}

variable "subnet1_public_id" {
  description = "" 
  type        = string
}

variable "subnet2_public_id" {
  description = "" 
  type        = string
}

variable "subnet3_private_id" {
  description = "" 
  type        = string
}

variable "subnet4_private_id" {
  description = "" 
  type        = string
}

output "rt_id" {
  description = "" 
  value       = join("", aws_route_table.module-infrastructure-network-rt.*.id)
}
