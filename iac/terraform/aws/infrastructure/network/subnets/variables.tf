variable "subnet1_public_cidr_block" {
  description = "" 
  default     = "10.0.1.0/24"
  type        = string
}

variable "subnet2_public_cidr_block" {
  description = "" 
  default     = "10.0.2.0/24"
  type        = string
}

variable "subnet3_private_cidr_block" {
  description = "" 
  default     = "10.0.3.0/24"
  type        = string
}

variable "subnet4_private_cidr_block" {
  description = "" 
  default     = "10.0.4.0/24"
  type        = string
}

variable "subnet1_map_public_ip" {
  description = "" 
  default     = true
  type        = bool
}

variable "subnet2_map_public_ip" {
  description = "" 
  default     = true
  type        = bool
}

variable "subnet3_map_public_ip" {
  description = "" 
  default     = true
  type        = bool
}

variable "subnet4_map_public_ip" {
  description = "" 
  default     = true
  type        = bool
}

variable "subnet1_public_tag_name" {
  description = "" 
  default     = "test-subnet1-public"
  type        = string
}

variable "subnet2_public_tag_name" {
  description = "" 
  default     = "test-subnet2-public"
  type        = string
}

variable "subnet3_private_tag_name" {
  description = "" 
  default     = "test-subnet3-private"
  type        = string
}

variable "subnet4_private_tag_name" {
  description = "" 
  default     = "test-subnet4-private"
  type        = string
}

variable "subnet1_public_tag_environment" {
  description = "" 
  default     = "Test"
  type        = string
}

variable "subnet2_public_tag_environment" {
  description = "" 
  default     = "Test"
  type        = string
}

variable "subnet3_private_tag_environment" {
  description = "" 
  default     = "Test"
  type        = string
}

variable "subnet4_private_tag_environment" {
  description = "" 
  default     = "Test"
  type        = string
}
