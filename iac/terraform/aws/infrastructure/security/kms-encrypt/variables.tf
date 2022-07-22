variable "kms_key_usage" {
  description = "" 
  default     = "ENCRYPT_DECRYPT"
  type        = string
}

variable "kms_key_rotation" {
  description = "" 
  default     = false
  type        = bool
}

variable "kms_deletion_days" {
  description = "" 
  default     = 10
  type        = number
}

variable "kms_enabled" {
  description = "" 
  default     = true
  type        = bool
}

variable "kms_tag_name" {
  description = "" 
  default     = "test-kms"
  type        = string
}

variable "kms_tag_environment" {
  description = "" 
  default     = "Test"
  type        = string
}
