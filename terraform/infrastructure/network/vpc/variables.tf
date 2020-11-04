variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "vpc_dns_hostnames" {
  default = "false"
}

variable "vpc_dns_support" {
  default = "true"
}

variable "vpc_instance_tenancy" {
  default = "default"
}

variable "vpc_tag_name" {
  default = "test-vpc"
}
