variable "region" {
  default = "us-west-2"
}

variable "project" {
  default = "titan-data"
}

provider "aws" {
  region = "${var.region}"
}

#
# CloudFront requires TLS certificates to be in the us-east-1 region, so we
# make ths provider available regardless of what the main region is.
#
provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
}

locals {
  domain = "${var.project}.io"
  domain-alt = replace("${var.project}.io", "-", "")
  dns-ttl = 300
}
