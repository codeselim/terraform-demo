




//remote states stored in S3 buckets
resource "aws_s3_bucket" "remote_state_bucket" {
  count = "${length(var.environments)}"
  bucket = "terraform-demo-remote-state-${var.environments[count.index]}"
  acl = "private"

  versioning {
    enabled = true
  }

  tags {
    Environment = "${var.environments[count.index]}"
    Project = "Terraform-demo-Edge-HAM-Mar2018"
    User = "sasa"
    Name = "s3-bucket-terraform-state-${count.index}"
  }
}