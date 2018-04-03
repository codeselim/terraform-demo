variable "region" {
  default = "eu-central-1"
  description = "The AWS region."
}

variable "environments" {
  type = "list"
  default = ["development", "production"]
}

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