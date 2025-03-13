variable "aws_region" {
  description = "AWS region to deploy resources into"
  default     = "eu-north-1"
}

variable "prefix" {
  description = "Prefix to add to resources"
  default     = "example"
}

variable "domain_name"{
  description = "Domain name for the CloudFront distribution"
  default     = "example.com"
}

variable "stage" {
  description = "Stage of the deployment"
  default     = "prod"
}

variable "zone_id" {
  description = "Route 53 zone ID"
}
