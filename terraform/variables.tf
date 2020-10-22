variable "cidr_vpc" {
  description = "CIDR block for the VPC"
}

variable "availability_zone" {
  description = "availability_zone to create subnet"
}

variable "cidr_subnet_jenkins" {
  description = "CIDR block for jenkins"
}

variable "cidr_subnet_web-servers" {
  description = "CIDR block for web-servers"
}
