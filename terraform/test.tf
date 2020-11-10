
#CREATE A NEW VPC--------------------------------------------------------------

resource "aws_vpc" "testvpc" {
  cidr_block           = var.test_vpc
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "testvpc"
  }
}

#DEFINE INTERNET GETEWAY-------------------------------------------------------

resource "aws_internet_gateway" "test_IGW" {
  vpc_id = aws_vpc.testvpc.id
  tags = {
    Name = "testvpc_IGW"
  }
}


#SETUP PUBLIC SUBNET-----------------------------------------------------------

resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.testvpc.id
  cidr_block              = var.test_subnet
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone
  tags = {
    Name = "test_public_subnet"
  }
}

#ADD ROUTING TABLE FOR PUBLIC SUBNET-------------------------------------------

resource "aws_route_table" "test_rt" {
  vpc_id = aws_vpc.testvpc.id

  route {
    gateway_id = aws_internet_gateway.test_IGW.id
    cidr_block = "0.0.0.0/0"
  }
}

#ROUTE TABLE ASSOCIATION--------------------------------------------------------

resource "aws_route_table_association" "rta_test_subnet" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.test_rt.id
}


#ADD SECURITY GROUP FOR PUBLIC SUBNET------------------------------------------
resource "aws_security_group" "test_sg" {
  name        = "test_sg"
  description = "allow_ssh"
  vpc_id      = aws_vpc.testvpc.id


  ingress {
    description = "allow_ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow_http"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_ssh_http"
  }
}


#CREATE KEY PAIR---------------------------------------------------------------

resource "aws_key_pair" "docker-key" {
  key_name   = "docker-key"
  public_key = "${file(var.test_key_pub)}"
}

resource "aws_instance" "dockerhost" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.test_subnet.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  key_name               = aws_key_pair.docker-key.key_name

  tags = {
    Name = "Dockerhost"
  }



  provisioner "local-exec" {
    command = <<EOT
      sleep 30;
      >dockerhost.ini;
      echo "[dockerhost]" | tee -a dockerhost.ini;
      echo "${aws_instance.dockerhost.public_ip} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.test_key_priv}" | tee -a dockerhost.ini;
      export ANSIBLE_HOST_KEY_CHECKING=False;
      ansible-playbook -u ${var.ansible_user} --private-key ${var.test_key_priv} -i dockerhost.ini /home/che/Documents/project/ansible/install_docker.yaml
      EOT
  }

}
