variable "region" {
  default = "us-west-2"
}

variable "project" {
  default = "titan-data"
}

provider "aws" {
  region = "${var.region}"
}

locals {
  domain = "${var.project}.io"
  domain-alt = replace("${var.project}.io", "-", "")
  dns-ttl = 300
}
