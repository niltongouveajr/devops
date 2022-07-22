data "external" "az_resource_group_exists" {
  program = ["/bin/bash", "-c", "echo \"{\\\"status\\\":\\\"$(az group exists --name ${var.az_resource_group_name} --subscription ${var.az_subscription})\\\"}\""]
}

resource "azurerm_resource_group" "az_resource_group" {
  depends_on = [data.external.az_resource_group_exists]
  count      = "${var.az_resource_group_exists == false ? 1 : 0}" 
  name       = var.az_resource_group_name
  location   = var.az_location
}
