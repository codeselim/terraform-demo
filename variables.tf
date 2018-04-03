variable "AWS_ACCESS_KEY_ID" {
  description = "AWS access key id, env variable"
}
variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS secret access key, env variable"
}
variable "AWS_SESSION_TOKEN" {
  description = "AWS session token, env variable"
}
variable "AWS_ASSUMRED_ROLE_ARN" {
  description = "AWS assumed role arn, env variable"
}

variable "environment" {
  default = "Almighty-Environment"
  description = "The environment that the infrastructure is running on e.g. development, production, almighty...etc"
}

variable "region" {
  default = "eu-central-1"
  description = "The AWS region."
}


data "aws_availability_zones" "availability_zones" {}

variable "public_subnets" {
  default = [ "10.0.24.0/24", "10.0.50.0/24" ]
  type = "list"
  description = "Public subnets"
}

variable "private_subnets" {
  default = ["10.0.100.0/24", "10.0.150.0/24"]
  type = "list"
  description = "Private subnets"
}


variable "servers_ami" {
  type = "map"
  default = {
    "us-east-1" = "ami-f652979b"
    "us-west-1" = "ami-7c4b331c"
    "eu-central-1" = "ami-5756ca38"
  }

  description = "The bastion host AMIs."
}

variable "availability_zones" {
  type = "list"
  default = ["eu-central-1a", "eu-central-1b"]
}