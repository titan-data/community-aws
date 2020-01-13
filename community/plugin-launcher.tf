#
# Infrastructure required for our various remote providers that need to push
# artifacts to the maven bucket.
#

resource "aws_iam_user" "plugin-launcher" {
  name = "plugin-launcher"
  path = "/automation/"
}

resource "aws_iam_user_policy" "plugin-launcher-maven" {
  name = "plugin-launcher-maven"
  user = "${aws_iam_user.plugin-launcher.name}"

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
