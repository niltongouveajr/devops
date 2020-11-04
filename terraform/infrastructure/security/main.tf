module "module-infrastructure-network-vpc" {
  source = "../network/vpc"
}

module "module-infrastructure-security-sg" {
  source = "./security-group"
  vpc_id = module.module-infrastructure-network-vpc.vpc_id
}
