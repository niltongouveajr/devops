output "az_resource_group_exists" {
  value = data.external.az_resource_group_exists.result.status
}

#output "az_resource_group_name" {
#  value = azurerm_resource_group.az_resource_group.name
#}
