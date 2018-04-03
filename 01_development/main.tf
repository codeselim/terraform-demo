module "vpc" {
  source          = "../modules/vpc"
  environment     = "${var.environment}"
  vpc_cidr        = "${var.vpc_cidr}"
  region          = "${var.region}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"
}

module "bastion" {
  source          = "../modules/bastion"
  servers_ami     = "${var.servers_ami}"
  region          = "${var.region}"
  environment     = "${var.environment}"
  private_subnets = "${var.private_subnets}"
  vpc_id          = "${module.vpc.vpc_id}"
  public_subnets  = "${var.public_subnets}"
}

module "server-some-purpose" {
  source          = "../modules/server-some-purpose"
  environment     = "${var.environment}"
  private_subnets = "${var.private_subnets}"
  servers_ami     = "${var.servers_ami}"
  region          = "${var.region}"
  vpc_id          = "${module.vpc.vpc_id}"
}