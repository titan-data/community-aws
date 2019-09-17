#
# Configure master DNS zone. Projects that need a sub-domain or individual
# records should be configured alongside the associated resources.
#

resource "aws_route53_zone" "domain" {
  name = "${local.domain}"
}

resource "aws_route53_zone" "domain-short" {
  name = "${local.domain-short}"
}
