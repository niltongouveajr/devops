output "repo_id" {
  description = "" 
  value       = join("", aws_codecommit_repository.module-pipeline-codecommit.*.id)
}

output "repo_arn" {
  description = "" 
  value       = aws_codecommit_repository.module-pipeline-codecommit.arn
}

output "repo_name" {
  value = var.repository_name
}
