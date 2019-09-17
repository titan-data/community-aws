#
# Configure the download bucket with public read access. We also configure
# logging so that we can run analytics on our downloads.
#

# Log bucket
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-logs"
  force_destroy = true
  acl = "log-delivery-write"
}

# Download bucket
resource "aws_s3_bucket" "download" {
  bucket = "${var.project}-download"
  acl = "public-read"
  force_destroy = true

  logging {
    target_bucket = "${aws_s3_bucket.logs.id}"
    target_prefix = "download/"
  }
}
