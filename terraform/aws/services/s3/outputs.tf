output "bucket_id" {
  description = "" 
  value       = join("", aws_s3_bucket.module-services-s3-bucket.*.id)
}
