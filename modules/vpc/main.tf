############################
########## VPC  ############

data "aws_availability_zones" "availability_zones" {}

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


########################################
############ deployer ############

resource "aws_key_pair" "deployer" {
  key_name   = "${var.environment}-deployer-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
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
  availability_zone = "${data.aws_availability_zones.availability_zones.names[count.index]}"

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
  availability_zone = "${data.aws_availability_zones.availability_zones.names[count.index]}"

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
