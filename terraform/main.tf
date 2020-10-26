provider "aws" {
  region = "us-east-1"
}

#CREATE A NEW VPC--------------------------------------------------------------

resource "aws_vpc" "myvpc" {
  cidr_block           = var.cidr_vpc
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "myvpc"
  }
}

#DEFINE INTERNET GETEWAY-------------------------------------------------------

resource "aws_internet_gateway" "my_IGW" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "myvpc_IGW"
  }
}


#SETUP PUBLIC SUBNET-----------------------------------------------------------

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.cidr_subnet_jenkins
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone
  tags = {
    Name = "jenkins_public_subnet"
  }
}

#ADD ROUTING TABLE FOR PUBLIC SUBNET-------------------------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    gateway_id = aws_internet_gateway.my_IGW.id
    cidr_block = "0.0.0.0/0"
  }
}

#ROUTE TABLE ASSOCIATION--------------------------------------------------------

resource "aws_route_table_association" "rta_public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.rt.id
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
