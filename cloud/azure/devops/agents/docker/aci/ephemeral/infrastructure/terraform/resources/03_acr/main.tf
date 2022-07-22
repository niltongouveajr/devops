data "external" "az_acr_available" {
  program = ["/bin/bash", "-c", "echo \"{\\\"status\\\":\\\"$(az acr check-name --name ${var.az_acr_name} --subscription ${var.az_subscription} --output yaml | grep nameAvailable | awk '{print $NF}')\\\"}\""]
}

resource "azurerm_container_registry" "az_acr" {
  depends_on          = [data.external.az_acr_available]
  count               = "${var.az_acr_available == true ? 1 : 0}"
  name                = var.az_acr_name
  resource_group_name = var.az_resource_group_name
  location            = var.az_location
  sku                 = "Basic"
  admin_enabled       = true
}
