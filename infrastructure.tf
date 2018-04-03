//variables (input variables) can be of type string (default), list, maps
// https://www.terraform.io/intro/getting-started/variables.html
variable AWS_ACCESS_KEY_ID {}
variable AWS_SECRET_ACCESS_KEY {}
variable AWS_SESSION_TOKEN {}
variable AWS_ASSUMRED_ROLE_ARN {}

variable "environment" {
  default = "Almighty-Environment"
  description = "The environment that the infrastructure is running on e.g. development, production, almighty...etc"
  type = "string" //(default type)
}

variable "region" {
  default = "eu-central-1"
  description = "The AWS region."
}

provider "aws" {
  region     = "${var.region}"
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  token = "${var.AWS_SESSION_TOKEN}"

  assume_role {
    role_arn     = "${var.AWS_ASSUMRED_ROLE_ARN}"
    //session_name = "playground"
    //external_id  = "EXTERNAL_ID"
  }
}

############################
########## VPC  ############

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "VPC"
  }
}

###################################
########## Networking  ############

data "aws_availability_zones" "availability_zones" {}


resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "igw"
  }
}

resource "aws_eip" "eip1" {  //eip1 for NAT gateway 1 - Az1
  vpc = true //eip is in the VPC
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "eip1"
  }
}

resource "aws_eip" "eip2" { //eip2 for NAT gateway 2 - Az2
  vpc = true
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "eip2"
  }
}

######## Subnets ########
variable "public_subnet_az1" {
  default = "10.0.24.0/24"
}

variable "public_subnet_az2" {
  default = "10.0.50.0/24"
}

variable "private_subnet_az1" {
  default = "10.0.100.0/24"
}

variable "private_subnet_az2" {
  default = "10.0.150.0/24"
}

resource "aws_subnet" "public_subnet_az1" {
  cidr_block = "${var.public_subnet_az1}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = false

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "public_subnet_az1"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  cidr_block = "${var.public_subnet_az2}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = false

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "public_subnet_az2"
  }

}

resource "aws_subnet" "private_subnet_az1" {
  cidr_block = "${var.private_subnet_az1}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = false

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "private_subnet_az1"
  }
}

resource "aws_subnet" "private_subnet_az2" {
  cidr_block = "${var.private_subnet_az2}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = false

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "private_subnet_az2"
  }
}


resource "aws_nat_gateway" "ngw_az1" {
  allocation_id = "${aws_eip.eip1.id}"
  subnet_id = "${aws_subnet.public_subnet_az1.id}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "ngw_az1"
  }
}

resource "aws_nat_gateway" "ngw_az2" {
  allocation_id = "${aws_eip.eip2.id}"
  subnet_id = "${aws_subnet.public_subnet_az2.id}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "ngw_az2"
  }
}

##### routing ####
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "public-rt"
  }
}

resource "aws_route_table" "private_az1" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "private_az1-rt"
  }
}

resource "aws_route_table" "private_az2" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "private_az2-rt"
  }
}

resource "aws_route" "public-route-internet" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.internet-gateway.id}"
}

resource "aws_route" "route_az1" {
  route_table_id = "${aws_route_table.private_az1.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.ngw_az1.id}"
}

resource "aws_route" "route_az2" {
  route_table_id = "${aws_route_table.private_az2.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.ngw_az2.id}"
}

//route table associations
resource "aws_route_table_association" "private_az1" {
  route_table_id = "${aws_route_table.private_az1.id}"
  subnet_id = "${aws_subnet.private_subnet_az1.id}"
}
resource "aws_route_table_association" "private_az2" {
  route_table_id = "${aws_route_table.private_az2.id}"
  subnet_id = "${aws_subnet.private_subnet_az2.id}"
}
resource "aws_route_table_association" "public_az1" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id = "${aws_subnet.public_subnet_az1.id}"
}
resource "aws_route_table_association" "public_az2" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id = "${aws_subnet.public_subnet_az2.id}"
}

########################################
############ EC2 instances ############
variable "servers_ami" {
  type = "map"
  default = {
    "us-east-1" = "ami-f652979b"
    "us-west-1" = "ami-7c4b331c"
    "eu-central-1" = "ami-5756ca38"
  }

  description = "The bastion host AMIs."
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "bastion" {
  ami                         = "${lookup(var.servers_ami, var.region)}"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = "${aws_subnet.public_subnet_az1.id}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.deployer.key_name}"

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "bastion"
  }
}

//Bastion Server
resource "aws_security_group" "sg" {
  vpc_id      = "${aws_vpc.vpc.id}"
  name        = "bastion-host"
  description = "Allow SSH to bastion host"

  ingress {
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

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "bastion-sg"
  }
}

###### servers sitting in the private subnets #####
resource "aws_instance" "server1" {
  ami                         = "${lookup(var.servers_ami, var.region)}"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = "${aws_subnet.private_subnet_az1.id}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.deployer.key_name}"

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "server1"
  }
}

resource "aws_instance" "server2" {
  ami                         = "${lookup(var.servers_ami, var.region)}"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = "${aws_subnet.private_subnet_az2.id}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.deployer.key_name}"

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "server2"
  }
}

