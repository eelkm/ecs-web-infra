output "cloudfront_url" {
  description = "The URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}/"
}

output "cloudfront_public_url" {
  value = "https://${var.domain_name}"
}