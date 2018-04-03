variable "vpc_cidr" {
  description = "The VPC CIDR"
}

variable "region" {
  description = "The AWS region."
}

variable "environment" {
  description = "The name of our environment, i.e. development."
}

variable "public_subnets" {
  type = "list"
  description = "Public subnets"
}

variable "private_subnets" {
  type = "list"
  description = "Private subnets"
}

output "public_subnets_ids" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "private_subnets_ids" {
  value = "${aws_subnet.private_subnet.*.id}"
}
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}