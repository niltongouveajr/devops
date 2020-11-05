variable "subnet1_public_cidr_block" {
  default = "10.0.1.0/24"
}

variable "subnet2_public_cidr_block" {
  default = "10.0.2.0/24"
}

variable "subnet3_private_cidr_block" {
  default = "10.0.3.0/24"
}

variable "subnet4_private_cidr_block" {
  default = "10.0.4.0/24"
}

variable "subnet1_map_public_ip" {
  default = "true"
}

variable "subnet2_map_public_ip" {
  default = "true"
}

variable "subnet3_map_public_ip" {
  default = "true"
}

variable "subnet4_map_public_ip" {
  default = "true"
}

variable "subnet1_public_tag_name" {
  default = "test-subnet1-public"
}

variable "subnet2_public_tag_name" {
  default = "test-subnet2-public"
}

variable "subnet3_private_tag_name" {
  default = "test-subnet3-private"
}

variable "subnet4_private_tag_name" {
  default = "test-subnet4-private"
}

variable "subnet1_public_tag_environment" {
  default = "Test"
}

variable "subnet2_public_tag_environment" {
  default = "Test"
}

variable "subnet3_private_tag_environment" {
  default = "Test"
}

variable "subnet4_private_tag_environment" {
  default = "Test"
}
