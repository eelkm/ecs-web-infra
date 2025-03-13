provider "aws" {
  region = var.aws_region
}

module "api" {
  source = "./api"
  prefix = var.prefix
  domain_name = var.domain_name
  aws_region = var.aws_region
  stage = var.stage
  zone_id = var.zone_id
}

module "frontend" {
  source = "./frontend"
  prefix = var.prefix
  domain_name = var.domain_name
  aws_region = var.aws_region
  zone_id = var.zone_id
}
