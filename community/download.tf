#
# Configure the download bucket with public read access. We also configure
# logging so that we can run analytics on our downloads.
#
# We want to expose a persistent URL to our assets,
# http://download.titan-data.io, and not have to hard-code the internal
# bucket name in our tools. Because of this, we run CloudFront on top of our
# S3 bucket in order to have TLS capabilities, among other benefits.
#

# Download bucket
resource "aws_s3_bucket" "download" {
  bucket            = "${var.project}-download"
  acl               = "public-read"

  logging {
    target_bucket   = "${aws_s3_bucket.logs.id}"
    target_prefix   = "download/"
  }

  website {
    index_document  = "index.html"
  }
}

# Public access policy for all objects
resource "aws_s3_bucket_policy" "download" {
  bucket = "${aws_s3_bucket.download.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",

      "Resource": "${aws_s3_bucket.download.arn}/*"
    }
  ]
}
EOF
}

# CloudFront
resource "aws_cloudfront_distribution" "download" {
  provider              = "aws.us-east-1"
  origin {
    domain_name         = "${aws_s3_bucket.download.bucket_domain_name}"
    origin_id           = "${aws_s3_bucket.download.id}-origin"
  }

  enabled               = true
  aliases               = [ "download.titan-data.io" ]
  default_root_object   = "index.html"
  price_class           = "PriceClass_100"

  default_cache_behavior {
    allowed_methods     = [ "DELETE", "GET", "HEAD", "OPTIONS", "PATCH",
                            "POST", "PUT" ]
    cached_methods      = [ "GET", "HEAD" ]
    target_origin_id    = "${aws_s3_bucket.download.id}-origin"
    forwarded_values {
      query_string      = true
      cookies {
        forward         = "all"
      }
    }
    viewer_protocol_policy = "allow-all"
  }

  logging_config {
    include_cookies     = false
    bucket              = "${aws_s3_bucket.logs.bucket_domain_name}"
    prefix              = "download-site/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn         = "${aws_acm_certificate_validation.main.certificate_arn}"
    ssl_support_method          = "sni-only"
    minimum_protocol_version    = "TLSv1.1_2016"
  }
}

# DNS
resource "aws_route53_record" "download" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "download"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.download.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.download.hosted_zone_id}"
    evaluate_target_health = false
  }
}
