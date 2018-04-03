variable "servers_ami" {
  type = "map"
  description = "The bastion host AMIs."
}

variable "region" {
  type = "string"
  description = "The AWS region."
}

variable "environment" {
  type = "string"
  description = "The name of our environment, i.e. development."
}

variable "private_subnets" {
  type = "list"
  description = "Private subnets"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "public_subnets" {
  type = "list"
  description = "Public subnets"
}