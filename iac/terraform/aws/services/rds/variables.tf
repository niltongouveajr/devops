variable "engine" {
  description = "" 
  default     = "mysql"
  type        = string
}

variable "engine_version" {
  description = "" 
  default     = "5.7"
  type        = number
}

variable "storage_type" {
  description = "" 
  default     = "gp2"
  type        = string
}

variable "allocated_storage" {
  description = "" 
  default     = 20
  type        = number
}

variable "instance_class" {
  description = "" 
  default     = "db.t2.micro"
  type        = string
}

variable "name" {
  description = "" 
  default     = "test-rds"
  type        = string
}

variable "port" {
  description = "" 
  default     = 3306
  type        = number
}

variable "identifier" {
  description = "" 
  default     = "test-rds"
  type        = string
}

variable "parameter_group_name" {
  description = "" 
  default     = "module-services-rds.mysql5.7"
  type        = string
}

variable "skip_final_snapshot" {
  description = "" 
  default     = true
  type        = bool
}
