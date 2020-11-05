resource "aws_internet_gateway" "module-infrastructure-network-igw" {
  vpc_id        = var.vpc_id
  tags = {
    Name        = var.internet_gateway_tag_name
    Environment = var.internet_gateway_tag_environment
  }
}
