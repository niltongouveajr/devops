data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnet1-public" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet1_public_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.subnet1_map_public_ip
  tags = {
    Name                  = var.subnet1_public_tag_name
    Environment           = var.subnet1_public_tag_environment
  }
}

resource "aws_subnet" "subnet2-public" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet2_public_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = var.subnet2_map_public_ip
  tags = {
    Name                  = var.subnet2_public_tag_name
    Environment           = var.subnet2_public_tag_environment
  }
}

resource "aws_subnet" "subnet3-private" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet3_private_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = var.subnet3_map_public_ip
  tags = {
    Name                  = var.subnet3_private_tag_name
    Environment           = var.subnet3_private_tag_environment
  }
}

resource "aws_subnet" "subnet4-private" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet4_private_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = var.subnet4_map_public_ip
  tags = {
    Name                  = var.subnet4_private_tag_name
    Environment           = var.subnet4_private_tag_environment
  }
}
