variable "aws_accesskey" {
  description = "Access key to access aws"
  type = "string"
}

variable "aws_secretkey" {
  description = "Secret key to access aws"
  type = "string"
}

variable "aws_dns_zone" {
  description = "route 53 zone"
  type = "string"
}

variable "ssh_key_name" {
  description = "use existing ssh key"
  type = "string"
}

variable "count_instances" {
  description = "count of instances"
  default = "10"
}
