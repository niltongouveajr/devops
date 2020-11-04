resource "aws_key_pair" "module-application-ec2-keypair" {
  key_name   = "test-ec2-keypair"
  public_key = file("infrastructure/security/key-pairs/ec2/key.pub")
}

resource "aws_instance" "module-application-ec2-instance" {
  key_name      = aws_key_pair.module-application-ec2-keypair.key_name
  ami           = var.ec2_ami
  instance_type = var.ec2_type
  user_data     = file("${path.module}/user_data.sh")
  subnet_id = var.subnet1_public_id
  associate_public_ip_address = true
  tags = {
    Name = var.ec2_name
  }
  vpc_security_group_ids = [
    var.sg_id
  ]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("infrastructure/security/key-pairs/ec2/key")
    host        = self.public_ip
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 20
  }
}

resource "aws_eip" "module-application-ec2-eip" {
  vpc      = true
  instance = aws_instance.module-application-ec2-instance.id
}
