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
  route_table_id = aws_route_table.public_rt.id
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

  ingress {
    description = "allow_http"
    from_port   = 8080
    to_port     = 8080
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

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = "${file(var.public_key)}"
}

resource "aws_instance" "jenkinsmaster" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = aws_key_pair.mykey.key_name

  tags = {
    Name = "Jenkins-master"
  }


  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      >jenkinsmaster.ini;
      echo "[jenkinsmaster]" | tee -a jenkinsmaster.ini;
      echo "${aws_instance.jenkinsmaster.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a jenkinsmaster.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
      ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i jenkinsmaster.ini /home/che/Documents/project/ansible/install_java.yaml /home/che/Documents/project/ansible/install_jenkins.yaml
    EOT
  }

}


resource "aws_instance" "jenkinsslave" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = aws_key_pair.mykey.key_name

  tags = {
    Name = "Jenkins-slave"
  }

  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      >jenkinsslave.ini;
      echo "[jenkinsslave]" | tee -a jenkinsslave.ini;
      echo "${aws_instance.jenkinsslave.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.private_key}" | tee -a jenkinsslave.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
      ansible-playbook -u ${var.ansible_user} --private-key ${var.private_key} -i jenkinsslave.ini /home/che/Documents/project/ansible/install_java.yaml /home/che/Documents/project/ansible/install_docker.yaml /home/che/Documents/project/ansible/install_git.yaml
      EOT
  }

}
