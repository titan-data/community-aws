#
# Infrastructure required for our various remote providers that need to push
# artifacts to the maven bucket.
#

resource "aws_iam_user" "titan-remotes" {
  name = "titan-remotes"
  path = "/automation/"
}

resource "aws_iam_user_policy" "titan-remotes-maven" {
  name = "titan-remotes-maven"
  user = "${aws_iam_user.titan-remotes.name}"

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
