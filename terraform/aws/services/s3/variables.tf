variable "s3_bucket_name" {
  default = "test-s3-bucket-niltongouveajr"
}

variable "s3_bucket_acl" {
  default = "private"
}

variable "s3_bucket_versioning" {
  default = "true"
}

variable "s3_bucket_lifecycle" {
  default = "true"
}

variable "s3_bucket_tag_name" {
  default = "test-s3-bucket"
}

variable "s3_bucket_tag_environment" {
  default = "Test"
}
