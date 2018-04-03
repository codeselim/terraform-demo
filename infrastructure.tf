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


resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "igw"
  }
}

resource "aws_eip" "eip" {  //eip1 for NAT gateway 1 - Az1
  vpc = true //eip is in the VPC
  count = "${length(var.public_subnets)}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "eip${count.index}"
  }
}

######## Subnets #######
resource "aws_subnet" "public_subnet" {
  count = "${length(var.public_subnets)}"
  cidr_block = "${var.public_subnets[count.index]}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = false
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "public_subnet-${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count =  "${length(var.private_subnets)}"
  cidr_block = "${var.private_subnets[count.index]}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = false
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "private_subnet-${count.index}"
  }
}


resource "aws_nat_gateway" "ngw" {
  count =  "${length(var.private_subnets)}"
  allocation_id = "${element(aws_eip.eip.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "ngw${count.index}"
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

resource "aws_route_table" "private" {
  count = "${length(var.private_subnets)}"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "private_rt-${count.index}"
  }
}

resource "aws_route" "public-route-internet" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.internet-gateway.id}"
}

resource "aws_route" "private_route" {
  count = "${length(var.private_subnets)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
}


//route table associations
resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"
  route_table_id = "${aws_route_table.public.id}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
}


########################################
############ EC2 instances ############

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "bastion" {
  ami = "${lookup(var.servers_ami, var.region)}"
  instance_type = "t2.micro"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  associate_public_ip_address = true
  key_name = "${aws_key_pair.deployer.key_name}"
  subnet_id                   = "${element(aws_subnet.public_subnet.*.id, 0)}"
  availability_zone           = "${var.availability_zones[0]}"

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
  count = "${length(var.private_subnets)}"
  ami                         = "${lookup(var.servers_ami, var.region)}"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  associate_public_ip_address = false
  availability_zone           = "${var.availability_zones[count.index]}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.deployer.key_name}"

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "server${count.index}}"
  }
}