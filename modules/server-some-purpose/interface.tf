variable "environment" {
  description = "The name of our environment, i.e. development."
}

variable "private_subnets" {
  type = "list"
  description = "Private subnets"
}

variable "servers_ami" {
  type = "map"
  description = "The bastion host AMIs."
}

variable "region" {
  type = "string"
  description = "The AWS region."
}

variable "vpc_id" {
  description = "VPC id"
}