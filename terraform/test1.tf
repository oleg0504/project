provider "aws" {
  region = "us-west-2"
}

#DEFINE VARIABLES-------------------------------------------------------------

variable "availability_zone" {
  description = "availability_zone to create subnet"
  default     = "us-west-2a"
}




#CREATE A NEW VPC--------------------------------------------------------------

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/22"
  instance_tenancy = "default"
  tags = {
    Name = "myvpc"
  }
}

#DEFINE INTERNET GETEWAY-------------------------------------------------------

resource "aws_internet_gateway" "myvpc_IGW" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "myvpc_IGW"
  }
}


#SETUP PUBLIC SUBNET-----------------------------------------------------------

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone
  tags = {
    Name = "my_public_subnet"
  }
}

#ADD ROUTING TABLE FOR PUBLIC SUBNET-------------------------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    gateway_id = aws_internet_gateway.myvpc_IGW.id
    cidr_block = "0.0.0.0/0"
  }
}

#ADD SECURITY GROUP FOR PUBLIC SUBNET------------------------------------------
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "allow_ssh"
  vpc_id      = aws_vpc.myvpc.id


  ingress {
    description = "allow_ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}


#CREATE KEY PAIR---------------------------------------------------------------

resource "aws_key_pair" "ec2key" {
  key_name   = "ec2key"
  public_key = file("/home/che/.ssh/id_rsa.pub")
}
