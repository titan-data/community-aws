#
# Configure a demo bucket with public read access.
#

resource "aws_s3_bucket" "demo" {
  bucket = "${var.project}-demo"
  acl = "public-read"
}

# Public access policy for all objects
resource "aws_s3_bucket_policy" "demo" {
  bucket = "${aws_s3_bucket.demo.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",

      "Resource": "${aws_s3_bucket.demo.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "titan-demo" {
  name = "titan-demo"
  path = "/automation/"
}

resource "aws_iam_user_policy" "titan-demo-bucket" {
  name = "titan-demo-bucket"
  user = "${aws_iam_user.titan-demo.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",

      "Resource": "${aws_s3_bucket.demo.arn}/*"
    }
  ]
}
EOF
}
