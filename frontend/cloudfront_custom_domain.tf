# Provider configuration for us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Certificate for the CloudFront distribution
resource "aws_acm_certificate" "cloudfront_cert" {
  provider = aws.us_east_1
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"
  subject_alternative_names = ["www.${var.domain_name}"]

  tags = {
    Project = "${var.prefix}"
  }
}

# Route 53 record for the ACM certificate validation
resource "aws_route53_record" "cloudfront_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

# A record for the main domain CloudFront distribution
resource "aws_route53_record" "cloudfront_record" {
  zone_id = var.zone_id
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# A record for the www subdomain CloudFront distribution
resource "aws_route53_record" "www_cloudfront_record" {
  zone_id = var.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
