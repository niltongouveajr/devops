variable "s3_bucket_name" {
  description = "" 
  default     = "test-s3-bucket-niltongouveajr"
  type        = string
}

variable "s3_bucket_acl" {
  description = "" 
  default     = "private"
  type        = string
}

variable "s3_bucket_versioning" {
  description = "" 
  default     = true
  type        = bool
}

variable "s3_bucket_lifecycle" {
  description = "" 
  default     = true
  type        = bool
}

variable "s3_bucket_tag_name" {
  description = "" 
  default     = "test-s3-bucket"
  type        = string
}

variable "s3_bucket_tag_environment" {
  description = "" 
  default     = "Test"
  type        = string
}
