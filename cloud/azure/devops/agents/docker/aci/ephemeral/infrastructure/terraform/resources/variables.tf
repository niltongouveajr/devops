
###############
### General ###
###############

variable "az_subscription" {
  default       = "00000000-0000-0000-0000-000000000000"
  description   = "Azure Subscription ID"
}

variable "az_location" {
  default       = "brazilsouth"
  description   = "Resources location"
}

######################
### Resource Group ###
######################

variable "az_resource_group_name" {
  default       = "DevOps"
  description   = "Name of the Resource Group"
}

variable "az_resource_group_exists" {
  type          = bool
  default       = false
  description   = "Variable with result of checking if Resource Group already exists"
}

###########
### ACR ###
###########

variable "az_acr_available" {
  type          = bool
  default       = true
  description   = "Variable with result of checking if Azure Container Registry is available"
}

variable "az_acr_name" {
  default       = "devops"
  description   = "Name of the Azure Container Registry"
}

####################
### Docker Image ###
####################

variable "az_docker_agent_image_version" {
  default       = "ubuntu-20.04"
  description   = "Docker agent image version"
}

variable "az_docker_agent_image_name" {
  default       = "devops/azure/azure-pipelines-agent"
  description   = "Docker agent image name"
}

############
### VNET ###
############

#variable "az_vnet_resource_group_name" {
#  default       = "DevOps-VNET"
#  description   = "Name of the VNET Resource Group"
#}


variable "az_vnet_resource_group_name" {
  default       = "DevOps"
  description   = "Name of the VNET Resource Group"
}

variable "az_vnet_resource_group_exists" {
  type          = bool
  default       = false
  description   = "Variable with result of checking if VNET Resource Group already exists"
}

variable "az_vnet_nsg_name" {
  default       = "DevOps"
  description   = "Name of the Network Security Group"
}

variable "az_vnet_nsg_exists" {
  type          = bool
  default       = false
  description   = "Variable with result of checking if Network Security Group already exists"
}

variable "az_vnet_name" {
  default       = "DevOps"
  description   = "Name of the VNET"
}

variable "az_vnet_exists" {
  type          = bool
  default       = false
  description   = "Variable with result of checking if VNET already exists"
}

variable "az_vnet_prefix" {
  default       = "10.0.0.0/24"
  description   = "Prefix of the VNET"
}

variable "az_vnet_subnet1_name" {
  default       = "storage"
  description   = "Name of the subnet 1"
}

variable "az_vnet_subnet1_prefix" {
  default       = "10.0.0.0/26"
  description   = "Prefix of the subnet 1"
}

variable "az_vnet_subnet2_name" {
  default       = "data"
  description   = "Name of the subnet 2"
}

variable "az_vnet_subnet2_prefix" {
  default       = "10.0.0.64/26"
  description   = "Prefix of the subnet 2"
}

variable "az_vnet_subnet3_name" {
  default       = "compute"
  description   = "Name of the subnet 3"
}

variable "az_vnet_subnet3_prefix" {
  default       = "10.10.0.128/26"
  description   = "Prefix of the subnet 3"
}

variable "az_vnet_subnet4_name" {
  default       = "azure-pipelines-agents"
  description   = "Name of the subnet 4"
}

variable "az_vnet_subnet4_prefix" {
  default       = "10.0.0.192/26"
  description   = "Prefix of the subnet 4"
}
