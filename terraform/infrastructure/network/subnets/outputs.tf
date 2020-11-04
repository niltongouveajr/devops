variable "vpc_id" {
  type = string
}

output "subnet1_public_id" {
  value = join("", aws_subnet.subnet1-public.*.id)
}

output "subnet2_public_id" {
  value = join("", aws_subnet.subnet2-public.*.id)
}
