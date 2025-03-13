variable "prefix" {
  description = "Prefix to add to resource names"
  type        = string
}

variable "domain_name"{
  description = "Domain name for the CloudFront distribution"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "zone_id" {
  description = "Route 53 zone ID"
  type        = string
}