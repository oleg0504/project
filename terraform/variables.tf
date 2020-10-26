variable "cidr_vpc" {
  description = "CIDR block for the VPC"
}


variable "cidr_subnet_jenkins" {
  description = "CIDR block for jenkins"
}


variable "availability_zone" {
  description = "availability_zone to create subnet"
}

variable "instance_type" {
  description = "type for aws EC2 instance"
}

variable "instance_ami" {
  description = "AMI for aws EC2 instance"
}
