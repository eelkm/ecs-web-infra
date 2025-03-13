output "cloudfront_public_url" {
  value = module.frontend.cloudfront_public_url
}

output "api_public_url" {
  value = module.api.api_public_url
}