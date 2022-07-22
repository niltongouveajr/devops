resource "null_resource" "az_docker_agent_image" {
  provisioner "local-exec" {
    command = <<EOH
      cd ../../../../agents/${var.az_docker_agent_image_version}
      docker build . -t ${var.az_acr_name}.azurecr.io/${var.az_docker_agent_image_name}:${var.az_docker_agent_image_version}
      az acr login --name ${var.az_acr_name}
      docker push ${var.az_acr_name}.azurecr.io/${var.az_docker_agent_image_name}:${var.az_docker_agent_image_version}
    EOH
    interpreter = ["/bin/bash", "-c"]
  }
}
