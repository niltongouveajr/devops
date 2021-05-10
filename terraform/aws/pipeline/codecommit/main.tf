resource "aws_codecommit_repository" "module-pipeline-codecommit" {
  repository_name = var.repository_name
  tags = {
    Name            = var.codecommit_tag_name
    Environment     = var.codecommit_tag_environment
  }
}
