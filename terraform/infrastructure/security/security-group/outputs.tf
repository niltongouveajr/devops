variable "vpc_id" {
  type = string
}

output "sg_id" {
  value = join("", aws_security_group.module-infrastructure-security-sg.*.id)
}
