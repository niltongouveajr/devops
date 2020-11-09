variable "kms_id" {
  description = "" 
  type        = string
}

output "rds_instance_id" {
  description = "" 
  value       = join("", aws_db_instance.module-services-rds.*.id)
}

output "rds_instance_address" {
  description = "" 
  value       = join("", aws_db_instance.module-services-rds.*.address)
}

output "rds_instance_endpoint" {
  description = "" 
  value       = join("", aws_db_instance.module-services-rds.*.endpoint)
}
