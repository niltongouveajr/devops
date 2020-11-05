provider "docker" {
}

resource "docker_container" "nginx" {
  image = var.docker_nginx_image_name
  name  = var.docker_nginx_local_name
  ports {
    internal = var.docker_nginx_internal_port
    external = var.docker_nginx_external_port
  }
}

resource "docker_image" "nginx" {
  name = "${var.docker_nginx_image_name}:${var.docker_nginx_image_version}"
}
