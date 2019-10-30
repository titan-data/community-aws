#
# Infrastructure required for titan-test automation. This includes a user
# with permission to write objects to the test buckets.
#

resource "aws_iam_user" "titan-test" {
  name = "titan-test"
  path = "/automation/"
}

resource "aws_iam_user_policy" "titan-test-policy" {
  name = "titan-test-policy"
  user = "${aws_iam_user.titan-test.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:DeleteObject"],

      "Resource": "${aws_s3_bucket.test.arn}/*"
    }
  ]
}
EOF
}
