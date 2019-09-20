#
# The artifacts bucket is a generic bucket for storing internal binaries and
# artifacts. For example, it's used to hold the slack inviter serverless
# deployment package.
#

resource "aws_s3_bucket" "artifacts" {
    bucket      = "${var.project}-artifacts"
}
