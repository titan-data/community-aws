#
# Configure the maven bucket with public read access.
#

resource "aws_s3_bucket" "maven" {
  bucket = "${var.project}-maven"
  acl = "public-read"
  force_destroy = true

  website {
    index_document = "index.html"
  }
}
