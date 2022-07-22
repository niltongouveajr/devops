output "az_acr_available" {
  value = data.external.az_acr_available.result.status
}
