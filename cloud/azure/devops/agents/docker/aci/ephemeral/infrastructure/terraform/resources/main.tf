module "az_cli_install_login" {
  source = "./01_authentication"
}

module "az_resource_group" {
  source = "./02_resource_group"
}

module "az_acr" {
  source = "./03_acr"
}

module "az_docker_agent_image" {
  source = "./04_agent_image"
}

module "az_vnet" {
  source = "./05_vnet"
}
