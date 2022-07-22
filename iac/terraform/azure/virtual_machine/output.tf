output "az_virtual_machine_private_key" {
  value     = tls_private_key.az_virtual_machine_private_key.private_key_pem
  sensitive = true
}
