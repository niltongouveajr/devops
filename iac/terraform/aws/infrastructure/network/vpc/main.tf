resource "aws_vpc" "module-infrastructure-network-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.vpc_dns_hostnames
  enable_dns_support   = var.vpc_dns_support
  instance_tenancy     = var.vpc_instance_tenancy
  tags = {
    Name               = var.vpc_tag_name
    Environment        = var.vpc_tag_environment
  }
}
