variable "vpc_id" {
  description = "" 
  type        = string
}

output "sg_id" {
  description = "" 
  value       = join("", aws_security_group.module-infrastructure-security-sg.*.id)
}
