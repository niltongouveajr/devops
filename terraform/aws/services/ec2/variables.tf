variable "ec2_ami" {
  default = "ami-02dc8ad50da58fffd"
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "ec2_tag_name" {
  default = "test-ec2"
}

variable "ec2_tag_environment" {
  default = "Test"
}
