output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.main.repository_url
}

output "api_public_url" {
  value = "https://${var.domain_name}"
}