#
# Configure a demo bucket with public read access. We also configure a static
# website at http://demo.titan-data.io.
#

resource "aws_s3_bucket" "demo" {
  bucket = "${var.project}-demo"
  acl = "public-read"

  website {
    index_document = "index.html"
  }
}

# Public access policy for all objects
resource "aws_s3_bucket_policy" "demo" {
  bucket = "${aws_s3_bucket.demo.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AddPerm",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",

      "Resource": "${aws_s3_bucket.demo.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "titan-demo" {
  name = "titan-demo"
  path = "/automation/"
}

resource "aws_iam_user_policy" "titan-demo-bucket" {
  name = "titan-demo-bucket"
  user = "${aws_iam_user.titan-demo.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:PutObject",

      "Resource": "${aws_s3_bucket.demo.arn}/*"
    }
  ]
}
EOF
}

# CloudFront
resource "aws_cloudfront_distribution" "demo" {
  provider              = "aws.us-east-1"
  origin {
    domain_name         = "${aws_s3_bucket.demo.bucket_domain_name}"
    origin_id           = "${aws_s3_bucket.demo.id}-origin"
  }

  enabled               = true
  aliases               = [ "demo.titan-data.io" ]
  default_root_object   = "index.html"
  price_class           = "PriceClass_100"

  default_cache_behavior {
    allowed_methods     = [ "DELETE", "GET", "HEAD", "OPTIONS", "PATCH",
                            "POST", "PUT" ]
    cached_methods      = [ "GET", "HEAD" ]
    target_origin_id    = "${aws_s3_bucket.demo.id}-origin"
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
    prefix              = "demo-site/"
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
resource "aws_route53_record" "demo" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "demo"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.demo.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.demo.hosted_zone_id}"
    evaluate_target_health = false
  }
}
