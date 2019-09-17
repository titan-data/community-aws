#
# Configure resources for titan-data.github.io. This includes a CNAME
# record for "www" that points to the site, as well as an "A" record for the
# top-level domain that points to GitHub as described here:
#
# https://help.github.com/en/articles/setting-up-an-apex-domain
#

resource "aws_route53_record" "www" {
  zone_id   = "${aws_route53_zone.domain.zone_id}"
  name      = "www"
  type      = "CNAME"
  records   = [ "titan-data.github.io" ]
  ttl       = "${local.dns-ttl}"
}

resource "aws_route53_record" "www-alias" {
  zone_id   = "${aws_route53_zone.domain.zone_id}"
  name      = ""
  type      = "A"
  records   = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
  ttl       = "${local.dns-ttl}"
}
