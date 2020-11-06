cidr_vpc            = "10.0.16.0/20"
cidr_subnet_jenkins = "10.0.16.0/24"
availability_zone   = "us-east-1a"
instance_type       = "t2.micro"
instance_ami        = "ami-0dba2cb6798deb6d8"
public_key          = "/home/che/.ssh/MyKeyPair.pub"
private_key         = "/home/che/.ssh/MyKeyPair.pem"
ansible_user        = "ubuntu"

#-------------------------------------------------------------------------------

test_vpc      = "10.0.16.0/20"
test_subnet   = "10.0.16.0/24"
test_key_pub  = "/home/che/.ssh/aws-key.pub"
test_key_priv = "/home/che/.ssh/aws-key"
