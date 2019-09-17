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

# CloudFront
resource "aws_cloudfront_distribution" "download-site" {
  origin {
    domain_name         = "${aws_s3_bucket.download.bucket_domain_name}"
    origin_id           = "${aws_s3_bucket.download.id}-origin"
  }

  enabled               = true
  aliases               = [ "download.titan-data.io" ]

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
    acm_certificate_arn         = "${aws_acm_certificate.main.arn}"
    ssl_support_method          = "sni-only"
    minimum_protocol_version    = "TLSv1.1_2016"
  }
}
