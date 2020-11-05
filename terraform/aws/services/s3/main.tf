resource "aws_s3_bucket" "module-services-s3-bucket" {
  bucket        = var.s3_bucket_name
  acl           = var.s3_bucket_acl
  tags = {
    Name        = var.s3_bucket_tag_name
    Environment = var.s3_bucket_tag_environment
  }
}
