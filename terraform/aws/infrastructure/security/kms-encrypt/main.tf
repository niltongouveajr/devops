resource "aws_kms_key" "module-infrastructure-security-kms" {
  key_usage               = var.kms_key_usage
  enable_key_rotation     = var.kms_key_rotation
  deletion_window_in_days = var.kms_deletion_days
  is_enabled              = var.kms_enabled
  tags = {
    Name        = var.kms_tag_name
    Environment = var.kms_tag_environment
  }
}

resource "aws_kms_key" "module-infrastructure-security-kms-encrypt" {
  provisioner "local-exec" {
    command = "${path.module}/kms-encrypt.sh <kms_id> <region> <input.yml> <output.yml.encrypted>"
    interpreter = ["/bin/bash", "-c"]
  }
}
