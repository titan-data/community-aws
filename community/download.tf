#
# Configure the download bucket with public read access.
#

resource "aws_s3_bucket" "download" {
  bucket = "${var.project}-download"
  force_destroy = true

  tags = {
    Name = "${var.project}-download"
  }
}

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
