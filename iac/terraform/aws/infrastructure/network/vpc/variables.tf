variable "vpc_cidr_block" {
  description = "" 
  default     = "10.0.0.0/16"
  type        = string
}

variable "vpc_dns_hostnames" {
  description = "" 
  default     = false
  type        = bool
}

variable "vpc_dns_support" {
  description = "" 
  default     = true
  type        = bool
}

variable "vpc_instance_tenancy" {
  description = "" 
  default     = "default"
  type        = string
}

variable "vpc_tag_name" {
  description = "" 
  default     = "test-vpc"
  type        = string
}

variable "vpc_tag_environment" {
  description = "" 
  default     = "Test"
  type        = string
}
