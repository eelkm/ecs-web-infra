variable "prefix" {
  description = "Prefix to add to resource names"
  type        = string
}

variable "domain_name"{
  description = "Domain name for the Api Gateway and ACM certificate"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "stage" {
  description = "Stage of the deployment"
  type        = string
}

variable "zone_id" {
  description = "Route 53 zone ID"
  type        = string
}