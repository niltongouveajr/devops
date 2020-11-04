output "vpc_id" {
  value = join("", aws_vpc.module-infrastructure-network-vpc.*.id)
}
