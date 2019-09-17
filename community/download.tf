#
# Configure the download bucket with public read access. We also configure
# logging so that we can run analytics on our downloads.
#
# We want to expose a persistent URL to our assets,
# http://download.titan-data.io, and not have to hard-code the internal
# bucket name in our tools. Because of this, we run CloudFront on top of our
# S3 bucket in order to have TLS capabilities, among other benefits.
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
