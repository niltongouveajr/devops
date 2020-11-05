resource "aws_route_table" "module-infrastructure-network-rt" {
  vpc_id         = var.vpc_id
  route {
    cidr_block   = "0.0.0.0/0"
    gateway_id   = var.igw_id
  }
  tags = {
    Name         = var.rt_tag_name
    Environment  = var.rt_tag_environment
  }
}

resource "aws_route_table_association" "subnet1-public" {
  subnet_id      = var.subnet1_public_id
  route_table_id = aws_route_table.module-infrastructure-network-rt.id
}

resource "aws_route_table_association" "subnet2-public" {
  subnet_id      = var.subnet2_public_id
  route_table_id = aws_route_table.module-infrastructure-network-rt.id
}
