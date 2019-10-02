#
# Infrastructure required for titan-server automation. This includes a user
# with permission to write objects to the maven and test buckets.
#

resource "aws_iam_user" "titan-server" {
  name = "titan-server"
  path = "/automation/"
}

resource "aws_iam_user_policy" "titan-server-maven" {
  name = "titan-server-maven"
  user = "${aws_iam_user.titan-server.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",

      "Resource": "${aws_s3_bucket.maven.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy" "titan-server-test" {
  name = "titan-server-test"
  user = "${aws_iam_user.titan-server.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",

      "Resource": "${aws_s3_bucket.test.arn}/*"
    }
  ]
}
EOF
}
