
/*
####################################
### AZURE CLI AND AUTHENTICATION ###
####################################

resource "null_resource" "az_cli_install_login" {
  provisioner "local-exec" {
    environment = {
      PASS = var.az_cli_install_login
    }
    command = <<EOH
      echo $PASS | sudo -S apt-get update && echo $PASS | sudo -S apt-get install curl apt-transport-https lsb-release gnupg jq -y
      curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
      AZ_REPO=$(lsb_release -cs)
      echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
      echo $PASS | sudo -S apt-get install azure-cli
      az login --allow-no-subscriptions >/dev/null
      az account set --subscription ${var.az_subscription} >/dev/null
      az account show
    EOH
    interpreter = ["/bin/bash", "-c"]
  }
}
*/

######################
### RESOURCE GROUP ###
######################

resource "azurerm_resource_group" "az_resource_group" {
  name       = var.az_resource_group_name
  location   = var.az_location
}

###############################
### NETWORK SECURITY GROUP ####
###############################

resource "azurerm_network_security_group" "az_nsg" {
  depends_on          = [ azurerm_resource_group.az_resource_group ]
  name                = var.az_nsg_name
  resource_group_name = var.az_resource_group_name
  location            = var.az_location
  security_rule {
    name                       = "Port_2233"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2233"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Port_80"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Port_443"
    priority                   = 1020
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#################
### PUBLIC IP ###
#################

resource "azurerm_public_ip" "az_public_ip" {
  depends_on          = [ azurerm_resource_group.az_resource_group ]
  name                = var.az_public_ip_name
  resource_group_name = var.az_resource_group_name
  location            = var.az_location
  allocation_method   = var.az_public_ip_allocation
  sku                 = var.az_public_ip_sku
}

############
### VNET ###
############

resource "azurerm_virtual_network" "az_vnet" {
  depends_on          = [ azurerm_resource_group.az_resource_group, azurerm_network_security_group.az_nsg ]
  name                = var.az_vnet_name
  resource_group_name = var.az_resource_group_name
  location            = var.az_location
  address_space       = [var.az_vnet_prefix]
  subnet {
    name              = var.az_vnet_subnet1_name
    address_prefix    = var.az_vnet_subnet1_prefix
    security_group    = azurerm_network_security_group.az_nsg.id
  }
}

###########
### NIC ###
###########

resource "azurerm_network_interface" "az_nic" {
  depends_on                      = [ azurerm_resource_group.az_resource_group, azurerm_virtual_network.az_vnet ]
  name                            = var.az_nic_name
  resource_group_name             = var.az_resource_group_name
  location                        = var.az_location
  ip_configuration {
    name                          = var.az_nic_config
    subnet_id                     = var.az_nic_subnet_id
    public_ip_address_id          = var.az_nic_public_ip_id
    private_ip_address_allocation = var.az_nic_allocation
  }
}

resource "azurerm_network_interface_security_group_association" "az_nic_nsg_association" {
  depends_on                = [azurerm_network_interface.az_nic]
  network_interface_id      = var.az_nic_id
  network_security_group_id = var.az_nic_sg_id
}

################
### SSH KEYS ###
################

resource "tls_private_key" "az_virtual_machine_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "az_virtual_machine_private_key_file" { 
  depends_on      = [ tls_private_key.az_virtual_machine_private_key ]
  filename        = var.az_virtual_machine_private_key_file
  content         = tls_private_key.az_virtual_machine_private_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "az_virtual_machine_public_key_file" { 
  depends_on      = [ tls_private_key.az_virtual_machine_private_key, local_file.az_virtual_machine_private_key_file ]
  filename        = var.az_virtual_machine_public_key_file
  content         = tls_private_key.az_virtual_machine_private_key.public_key_openssh
  file_permission = "0600"
}

##################
### CLOUD-INIT ###
##################

data "template_cloudinit_config" "az_virtual_machine_cloudinit_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content      = templatefile("./cloud-init/cloud-init-generic.tpl", { CLOUD_INIT_CONFIG = "true" })
  }
}

#######################
### VIRTUAL MACHINE ###
#######################

resource "azurerm_linux_virtual_machine" "az_virtual_machine" {
  depends_on                      = [ azurerm_resource_group.az_resource_group, tls_private_key.az_virtual_machine_private_key, data.template_cloudinit_config.az_virtual_machine_cloudinit_config, azurerm_network_interface.az_nic ]
  name                            = var.az_virtual_machine_name
  computer_name                   = var.az_virtual_machine_name
  resource_group_name             = var.az_resource_group_name
  location                        = var.az_location
  size                            = var.az_virtual_machine_size
  disable_password_authentication = true
  admin_username                  = var.az_virtual_machine_username
  admin_ssh_key {
    username                      = var.az_virtual_machine_username
    public_key                    = tls_private_key.az_virtual_machine_private_key.public_key_openssh
  }
  custom_data                     = data.template_cloudinit_config.az_virtual_machine_cloudinit_config.rendered
  network_interface_ids           = [
    var.az_nic_id,
  ]
  os_disk {
    name                          = var.az_virtual_machine_os_disk_name
    caching                       = var.az_virtual_machine_os_disk_caching
    storage_account_type          = var.az_virtual_machine_os_disk_storage
  }
  source_image_reference {
    publisher                     = var.az_virtual_machine_source_publisher
    offer                         = var.az_virtual_machine_source_offer
    sku                           = var.az_virtual_machine_source_sku
    version                       = var.az_virtual_machine_source_version
  }
}
