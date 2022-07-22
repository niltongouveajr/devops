resource "null_resource" "az_cli_install_login" {
  provisioner "local-exec" {
    command = <<EOH
      sudo apt-get update && sudo apt-get install curl apt-transport-https lsb-release gnupg jq -y
      curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
      AZ_REPO=$(lsb_release -cs)
      echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
      sudo apt-get update && sudo apt-get install azure-cli
      az login --allow-no-subscriptions >/dev/null
      az account set --subscription ${var.az_subscription} >/dev/null
      az account show
    EOH
    interpreter = ["/bin/bash", "-c"]
  }
}
