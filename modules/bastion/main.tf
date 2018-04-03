data "aws_availability_zones" "availability_zones" {}

resource "aws_instance" "bastion" {
  ami = "${lookup(var.servers_ami, var.region)}"
  instance_type = "t2.micro"
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  associate_public_ip_address = true
  key_name                    = "${var.environment}-deployer-key"
  subnet_id                   = "${element(var.public_subnets, 0)}" //changed to input variable it was: ${element(aws_subnet.public_subnet.*.id, 0)}
  availability_zone           = "${data.aws_availability_zones.availability_zones.names[count.index]}"

  tags {
    Environment = "${var.environment}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "bastion"
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