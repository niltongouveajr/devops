output "vpc_id" {
  description = "" 
  value       = join("", aws_vpc.module-infrastructure-network-vpc.*.id)
}
