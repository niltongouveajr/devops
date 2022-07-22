resource "aws_s3_bucket" "module-services-s3-bucket" {
  bucket            = var.s3_bucket_name
  acl               = var.s3_bucket_acl
  versioning {
    enabled         = var.s3_bucket_versioning
  }
  lifecycle_rule {
    enabled         = var.s3_bucket_lifecycle
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
  tags = {
    Name            = var.s3_bucket_tag_name
    Environment     = var.s3_bucket_tag_environment
  }
}

resource "aws_s3_bucket_public_access_block" "module-services-s3-bucket-restrict" {
  bucket = aws_s3_bucket.module-services-s3-bucket.id
  block_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}
