
###############
### GENERAL ###
###############

variable "az_subscription" {
  default       = "00000000-0000-0000-0000-000000000000"
  description   = "Azure Subscription ID"
}

variable "az_location" {
  default       = "eastus"
  description   = "Resources location"
}

######################
### AUTHENTICATION ###
######################

variable "az_cli_install_login" {
  default       = ""
  sensitive     = true
  description   = "Type root password to use in sudo command (be careful, what you type will appear on the screen):"
}

######################
### RESOURCE GROUP ###
######################

variable "az_resource_group_name" {
  default       = "DevOps-Sandbox"
  description   = "Name of the Resource Group"
}

##############################
### NETWORK SECURITY GROUP ###
##############################

variable "az_nsg_name" {
  default       = "devops-sandbox01"
  description   = "Name of the Network Security Group"
}

#################
### PUBLIC IP ###
#################

variable "az_public_ip_name" {
  default       = "devops-sandbox01"
  description   = "Name of the Public IP (e.g: devops-sandbox01)"
}

variable "az_public_ip_allocation" {
  default       = "Static"
  description   = "Allocation method of the Public IP (e.g: Static/Dynamic)"
}

variable "az_public_ip_sku" {
  default       = "Basic"
  description   = "SKU of the Public IP"
}

############
### VNET ###
############

variable "az_vnet_name" {
  default       = "AZ_SRV_DevOps_Sandbox"
  description   = "Name of the VNET"
}

variable "az_vnet_prefix" {
  default       = "10.26.40.0/24"
  description   = "Prefix of the VNET"
}

variable "az_vnet_subnet1_name" {
  default       = "servers"
  description   = "Name of the subnet 1"
}

variable "az_vnet_subnet1_prefix" {
  default       = "10.26.40.0/24"
  description   = "Prefix of the subnet 1"
}

###########
### NIC ###
###########

variable "az_nic_config" {
  default       = "devops-sandbox01"
  description   = "Name of the NIC configuration (e.g: devops-sandbox01)"
}

variable "az_nic_name" {
  default       = "devops-sandbox01"
  description   = "Name of the NIC (e.g: devops-sandbox01)"
}

variable "az_nic_subnet_id" {
  default       = "/subscriptions/569b59c5-c099-4db6-a5e8-cb51a90f4ed9/resourceGroups/devops-sandbox/providers/Microsoft.Network/virtualNetworks/AZ_SRV_DevOps_Sandbox/subnets/servers"
  description   = "ID of the subnet"
}

variable "az_nic_public_ip_id" {
  default       = "/subscriptions/569b59c5-c099-4db6-a5e8-cb51a90f4ed9/resourceGroups/devops-sandbox/providers/Microsoft.Network/publicIPAddresses/devops-sandbox01"
  description   = "ID of the public IP (e.g: /subscriptions/569b59c5-c099-4db6-a5e8-cb51a90f4ed9/resourceGroups/devops-sandbox/providers/Microsoft.Network/publicIPAddresses/devops-sandbox01)"
}

variable "az_nic_id" {
  default       = "/subscriptions/569b59c5-c099-4db6-a5e8-cb51a90f4ed9/resourceGroups/devops-sandbox/providers/Microsoft.Network/networkInterfaces/devops-sandbox01"
  description   = "ID of the NIC (e.g: /subscriptions/569b59c5-c099-4db6-a5e8-cb51a90f4ed9/resourceGroups/devops-sandbox/providers/Microsoft.Network/networkInterfaces/devops-sandbox01)"
}

variable "az_nic_sg_id" {
  default       = "/subscriptions/569b59c5-c099-4db6-a5e8-cb51a90f4ed9/resourceGroups/devops-sandbox/providers/Microsoft.Network/networkSecurityGroups/devops-sandbox01"
  description   = "ID of the network security group (e.g: /subscriptions/569b59c5-c099-4db6-a5e8-cb51a90f4ed9569b59c5-c099-4db6-a5e8-cb51a90f4ed9/resourceGroups/devops-sandbox/providers/Microsoft.Network/networkSecurityGroups/devops-sandbox01)"
}

variable "az_nic_allocation" {
  default       = "Dynamic"
  description   = "Allocation method of the NIC"
}

#######################
### VIRTUAL MACHINE ###
#######################

variable "az_virtual_machine_name" {
  default       = "devops-sandbox01"
  description   = "Name of the virtual machine (e.g: devops-sandbox01)"
}

variable "az_virtual_machine_size" {
  default       = "Standard_D2s_v3"
  description   = "Size of the virtual machine"
}

variable "az_virtual_machine_username" {
  default       = "devops"
  description   = "Username of the virtual machine (e.g: devops)"
}

variable "az_virtual_machine_private_key_file" {
  default       = "keys/devops-sandbox01.pem"
  description   = "Private key file for the virtual machine (e.g: keys/devops-sandbox01.pem)"
}

variable "az_virtual_machine_public_key_file" {
  default       = "keys/devops-sandbox01.pub"
  description   = "Public key file for the virtual machine (e.g: keys/devops-sandbox01.pub)"
}

variable "az_virtual_machine_ssh_key_name" {
  default       = "devops-sandbox01"
  description   = "SSH key name of the virtual machine (e.g: devops-sandbox01)"
}

variable "az_virtual_machine_os_disk_name" {
  default       = "devops-sandbox01"
  description   = "OS disk name of the virtual machine (e.g: devops-sandbox01)"
}

variable "az_virtual_machine_os_disk_caching" {
  default       = "ReadWrite"
  description   = "OS disk caching of the virtual machine"
}

variable "az_virtual_machine_os_disk_storage" {
  default       = "Premium_LRS"
  description   = "OS disk storage of the virtual machine"
}

variable "az_virtual_machine_source_publisher" {
  default       = "Canonical"
  description   = "Source image publisher for the virtual machine"
}

#az vm image list --publisher Canonical --output table --all | grep 20_04-lts | grep -v gen2
#az vm image list-skus --publisher Canonical --offer 0001-com-ubuntu-server-focal --location westus --output table
variable "az_virtual_machine_source_offer" {
  default       = "0001-com-ubuntu-server-focal"
  #default       = "0001-com-ubuntu-server-jammy"
  description   = "Source image offer referente for the virtual machine"
}

variable "az_virtual_machine_source_sku" {
  default       = "20_04-lts-gen2"
  #default       = "22_04-lts-gen2"
  description   = "Source image sku referente for the virtual machine"
}

variable "az_virtual_machine_source_version" {
  default       = "latest"
  description   = "Source image version for the virtual machine"
}
