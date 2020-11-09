variable "ec2_ami" {
  description = "" 
  default     = "ami-02dc8ad50da58fffd"
  type        = string
}

variable "ec2_type" {
  description = "" 
  default     = "t2.micro"
  type        = string
}

variable "ec2_tag_name" {
  description = "" 
  default     = "test-ec2"
  type        = string
}

variable "ec2_tag_environment" {
  description = "" 
  default     = "Test"
  type        = string
}
