variable "region" {
  default = "us-west-2"
}

variable "project" {
  default = "titan-data-test"
}

provider "aws" {
  region = "${var.region}"
}
