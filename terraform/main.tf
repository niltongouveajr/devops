module "module-infrastructure-network-vpc" {
  source = "./infrastructure/network/vpc"
}

module "module-infrastructure-network-subnets" {
  source = "./infrastructure/network/subnets"
  vpc_id = module.module-infrastructure-network-vpc.vpc_id
}

module "module-infrastructure-network-igw" {
  source = "./infrastructure/network/internet-gateway"
  vpc_id = module.module-infrastructure-network-vpc.vpc_id
}

module "module-infrastructure-network-rt" {
  source = "./infrastructure/network/route-tables"
  vpc_id = module.module-infrastructure-network-vpc.vpc_id
  igw_id = module.module-infrastructure-network-igw.igw_id
  subnet1_public_id = module.module-infrastructure-network-subnets.subnet1_public_id
  subnet2_public_id = module.module-infrastructure-network-subnets.subnet2_public_id
}

module "module-infrastructure-security-sg" {
  source = "./infrastructure/security/security-group"
  vpc_id = module.module-infrastructure-network-vpc.vpc_id
}

module "module-application-ec2" {
  source = "./application/ec2"
  sg_id = module.module-infrastructure-security-sg.sg_id
  subnet1_public_id = module.module-infrastructure-network-subnets.subnet1_public_id
  subnet2_public_id = module.module-infrastructure-network-subnets.subnet2_public_id
}
