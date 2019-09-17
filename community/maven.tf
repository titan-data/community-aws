#
# Configure the maven bucket with public read access.
#

resource "aws_s3_bucket" "maven" {
  bucket = "${var.project}-maven"
  force_destroy = true

  tags = {
    Name = "${var.project}-maven"
  }
}

resource "aws_s3_bucket_policy" "maven" {
  bucket = "${aws_s3_bucket.maven.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",

      "Resource": "${aws_s3_bucket.maven.arn}/*"
    }
  ]
}
EOF
}
