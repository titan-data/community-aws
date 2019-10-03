#
# Common test resources for various endtoend tests requiring S3.
#

resource "aws_s3_bucket" "test" {
  bucket = "${var.project}-testdata"
}
