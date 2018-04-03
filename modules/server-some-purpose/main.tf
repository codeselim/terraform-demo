###### servers sitting in the private subnets #####

data "aws_availability_zones" "availability_zones" {}

resource "aws_instance" "server" {
  count = "${length(var.private_subnets)}"
  ami                         = "${lookup(var.servers_ami, var.region)}"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = "${element(var.private_subnets, count.index)}"
  associate_public_ip_address = false
  availability_zone           = "${data.aws_availability_zones.availability_zones.names[count.index]}"
  instance_type               = "t2.micro"
  key_name                    = "${var.environment}-deployer-key"

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "server${count.index}"
  }
}

//Bastion Server
resource "aws_security_group" "sg" {
  vpc_id      = "${var.vpc_id}"
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