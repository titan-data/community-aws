#
# Common test resources for various endtoend tests requiring S3. This is also
# made publicly read-only to support testing the s3web provider
# (which requires HTTP access).
#

resource "aws_s3_bucket" "test" {
  bucket = "${var.project}-testdata"
  acl = "public-read"

  website {
    index_document = "index.html"
  }
}

# Public access policy for all objects
resource "aws_s3_bucket_policy" "test" {
  bucket = "${aws_s3_bucket.test.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",

      "Resource": "${aws_s3_bucket.test.arn}/*"
    }
  ]
}
EOF
}
