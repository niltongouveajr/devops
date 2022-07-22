data "external" "az_vnet_resource_group_exists" {
  program = ["/bin/bash", "-c", "echo \"{\\\"status\\\":\\\"$(az group exists --name ${var.az_vnet_resource_group_name} --subscription ${var.az_subscription})\\\"}\""]
}

resource "azurerm_resource_group" "az_vnet_resource_group" {
  depends_on = [data.external.az_vnet_resource_group_exists]
  count      = "${var.az_vnet_resource_group_exists == false ? 1 : 0}"
  name       = var.az_vnet_resource_group_name
  location   = var.az_location
}

data "external" "az_vnet_nsg_exists" {
  program = ["/bin/bash", "-c", "echo \"{\\\"status\\\":\\\"$(if [[ -z `az network nsg show --name ${var.az_vnet_nsg_name} --resource-group ${var.az_vnet_resource_group_name}` ]]; then echo false ; fi)\\\"}\""]
}

resource "azurerm_network_security_group" "az_vnet_nsg" {
  depends_on          = [azurerm_resource_group.az_vnet_resource_group, data.external.az_vnet_nsg_exists]
  count               = "${var.az_vnet_nsg_exists == false ? 1 : 0}"
  name                = var.az_vnet_nsg_name 
  resource_group_name = var.az_vnet_resource_group_name
  location            = var.az_location
}

data "external" "az_vnet_exists" {
  program = ["/bin/bash", "-c", "echo \"{\\\"status\\\":\\\"$(if [[ -z `az network vnet show --name ${var.az_vnet_name} --resource-group ${var.az_vnet_resource_group_name}` ]]; then echo false ; fi)\\\"}\""]
}

resource "azurerm_virtual_network" "az_vnet" {
  depends_on          = [ azurerm_resource_group.az_vnet_resource_group, azurerm_network_security_group.az_vnet_nsg, data.external.az_vnet_exists ]
  count               = "${var.az_vnet_exists == false ? 1 : 0}"
  name                = var.az_vnet_name
  resource_group_name = var.az_vnet_resource_group_name
  location            = var.az_location
  address_space       = [var.az_vnet_prefix]
  subnet {
    name              = var.az_vnet_subnet1_name
    address_prefix    = var.az_vnet_subnet1_prefix
    security_group    = azurerm_network_security_group.az_vnet_nsg[0].id
  }
  subnet {
    name              = var.az_vnet_subnet2_name
    address_prefix    = var.az_vnet_subnet2_prefix
    security_group    = azurerm_network_security_group.az_vnet_nsg[0].id
  }
  subnet {
    name              = var.az_vnet_subnet3_name
    address_prefix    = var.az_vnet_subnet3_prefix
    security_group    = azurerm_network_security_group.az_vnet_nsg[0].id
  }
  subnet {
    name              = var.az_vnet_subnet4_name
    address_prefix    = var.az_vnet_subnet4_prefix
    security_group    = azurerm_network_security_group.az_vnet_nsg[0].id
  }
}
