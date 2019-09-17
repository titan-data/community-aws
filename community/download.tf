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
  force_destroy = true

  logging {
    target_bucket = "${aws_s3_bucket.logs.id}"
    target_prefix = "download/"
  }
}

# Public access
resource "aws_s3_bucket_policy" "download" {
  bucket = "${aws_s3_bucket.download.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",

      "Resource": "${aws_s3_bucket.download.arn}/*"
    }
  ]
}
EOF
}
