#
# Infrastructure required for zfs-releases automation. This is just a user
# with permission to write objects under "/zfs-releases" in the download
# bucket.
#

resource "aws_iam_user" "zfs-releases" {
  name = "zfs-releases"
  path = "/automation/"
}

resource "aws_iam_user_policy" "zfs-releases-download" {
  name = "zfs-releases-download"
  user = "${aws_iam_user.zfs-releases.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",

      "Resource": "${aws_s3_bucket.download.arn}/zfs-releases/*"
    }
  ]
}
EOF
}
