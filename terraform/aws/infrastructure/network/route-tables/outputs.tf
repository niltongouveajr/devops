variable "vpc_id" {
  type = string
}

variable "igw_id" {
  type = string
}

variable "subnet1_public_id" {
  type = string
}

variable "subnet2_public_id" {
  type = string
}

variable "subnet3_private_id" {
  type = string
}

variable "subnet4_private_id" {
  type = string
}

output "rt_id" {
  value = join("", aws_route_table.module-infrastructure-network-rt.*.id)
}
