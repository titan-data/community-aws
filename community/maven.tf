#
# Configure the maven bucket with public read access. The public-read ACL
# does not automatically make all objects public, so we also add a policy to
# make all objects readable.
#

resource "aws_s3_bucket" "maven" {
  bucket = "${var.project}-maven"
  acl = "public-read"

  website {
    index_document = "index.html"
  }
}

# Public access policy for all objects
resource "aws_s3_bucket_policy" "maven" {
  bucket = "${aws_s3_bucket.maven.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",

      "Resource": "${aws_s3_bucket.maven.arn}/*"
    }
  ]
}
EOF
}

# CloudFront
resource "aws_cloudfront_distribution" "maven" {
  provider              = "aws.us-east-1"
  origin {
    domain_name         = "${aws_s3_bucket.maven.bucket_domain_name}"
    origin_id           = "${aws_s3_bucket.maven.id}-origin"
  }

  enabled               = true
  aliases               = [ "maven.titan-data.io" ]
  default_root_object   = "index.html"
  price_class           = "PriceClass_100"

  default_cache_behavior {
    allowed_methods     = [ "DELETE", "GET", "HEAD", "OPTIONS", "PATCH",
                            "POST", "PUT" ]
    cached_methods      = [ "GET", "HEAD" ]
    target_origin_id    = "${aws_s3_bucket.maven.id}-origin"
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
    prefix              = "maven-site/"
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
resource "aws_route53_record" "maven" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "maven"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.maven.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.maven.hosted_zone_id}"
    evaluate_target_health = false
  }
}
