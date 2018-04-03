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

terraform {
  backend "s3" {
    bucket = "terraform-demo-remote-state-production"
    key = "terraform.tfstate"
    region = "eu-central-1"
  }
}