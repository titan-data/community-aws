#
# Configure master DNS zone. Projects that need a sub-domain or individual
# records should be configured alongside the associated resources.
#
# This also sets up additional domain-wide resources, such as a TLS certificate
# that can be used in CloudFront configuration.
#

resource "aws_route53_zone" "main" {
  name = "${local.domain}"
}

#
# Java packages do not allow hyphens in them, so we use the hyphen-less version
# io.titandata. While we don't actually provision any resources beneath this
# domain, we do keep it registered to ensure that no one else could
# inadvertently take ownership.
#
resource "aws_route53_zone" "alt" {
  name = "${local.domain-alt}"
}

# Configure a TLS certificate
resource "aws_acm_certificate" "main" {
  domain_name                   = "${local.domain}"
  subject_alternative_names     = [ "*.${local.domain}" ]
  validation_method             = "DNS"
}

#
# DNS validation records. Note that because the alternative names are part of
# the same domain, there is only one required CNAME record.
#
resource "aws_route53_record" "validation" {
  name      = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_name}"
  type      = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_type}"
  zone_id   = "${aws_route53_zone.main.zone_id}"
  records   = [ "${aws_acm_certificate.main.domain_validation_options.0.resource_record_value}" ]
  ttl       = "${local.dns-ttl}"
}

# Wait for validation to complete
resource "aws_acm_certificate_validation" "main" {
  certificate_arn           = "${aws_acm_certificate.main.arn}"
  validation_record_fqdns   = [
    "${aws_route53_record.validation.fqdn}"
  ]
}
