#
# Configure master resources for hosting sites. Projects that need a sub-domain
# or individual records should be configured alongside the associated resources.
#
# This also sets up additional domain-wide resources, such as a TLS certificate
# that can be used in CloudFront configuration.
#

# Main DNS Zone
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

#
# Configure a TLS certificate. Due to CloudFront restrictions, this must be
# provisioned in the us-east-1 region.
#
resource "aws_acm_certificate" "main" {
  provider                      = "aws.us-east-1"
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

# Shared S3 bucket for access logging
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-logs"
  force_destroy = true
  acl = "log-delivery-write"
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = "${aws_s3_bucket.logs.id}"

  block_public_acls   = true
  block_public_policy = true
}
