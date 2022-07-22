data "aws_kms_secrets" "module-infrastructure-security-kms-creds" {
  secret {
    name    = "kms-mysql-creds"
    payload = file("../../infrastructure/security/kms-encrypt/kms-mysql-creds.yml.encrypted")
  }
}

locals {
  rds_creds = yamldecode(data.aws_kms_secrets.module-infrastructure-security-kms-creds.plaintext["kms-mysql-creds"])
}

resource "aws_db_instance" "module-services-rds" {
  engine               = var.rds_engine
  engine_version       = var.rds_engine_version
  storage_type         = var.rds_storage_type
  allocated_storage    = var.rds_allocated_storage
  instance_class       = var.rds_instance_class
  name                 = var.rds_name
  username             = local.rds_creds.username
  password             = local.rds_creds.password
  port                 = var.rds_port
  identifier           = var.rds_identifier
  parameter_group_name = var.rds_parameter_group_name
  skip_final_snapshot  = var.rds_skip_final_snapshot
}
