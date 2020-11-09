variable "vpc_id" {
  description = "" 
  type        = string
}

output "subnet1_public_id" {
  description = "" 
  value       = join("", aws_subnet.subnet1-public.*.id)
}

output "subnet2_public_id" {
  description = "" 
  value       = join("", aws_subnet.subnet2-public.*.id)
}

output "subnet3_private_id" {
  description = "" 
  value       = join("", aws_subnet.subnet3-private.*.id)
}

output "subnet4_private_id" {
  description = "" 
  value       = join("", aws_subnet.subnet4-private.*.id)
}
