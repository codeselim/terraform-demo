resource "aws_s3_bucket" "remote_state_dev01" {
  bucket = "kreditech-remote-state-${var.environment}-01"
  acl = "private"

  versioning {
    enabled = true
  }

  tags {
    Environment = "${var.environment}",
    CostCenter="engineering",
    Name="${var.environment}-remote-state-01"
  }
}

resource "aws_s3_bucket" "remote_state_dev02" {
  bucket = "kreditech-remote-state-${var.environment}-02"
  acl = "private"

  versioning {
    enabled = true
  }

  tags {
    Environment = "${var.environment}",
    CostCenter="engineering",
    Name="${var.environment}-remote-state-02"
  }
