output "az_vnet_resource_group_exists" {
  value = data.external.az_vnet_resource_group_exists.result.status
}

output "az_vnet_nsg_exists" {
  value = data.external.az_vnet_nsg_exists.result.status
}

output "az_vnet_exists" {
  value = data.external.az_vnet_exists.result.status
}
