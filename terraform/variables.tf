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

variable "public_key" {

}

variable "private_key" {

}



variable "ansible_user" {

}


#--------------------------------------------------------------------------------
variable "test_vpc" {
  description = "CIDR block for the VPC"
}


variable "test_subnet" {
  description = "CIDR block for jenkins"
}


variable "test_key_pub" {

}

variable "test_key_priv" {

}
