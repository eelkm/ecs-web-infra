resource "aws_ecr_repository" "main" {
  name = "${var.prefix}-repository"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = var.prefix
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name

  policy = <<POLICY
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only the most recent image",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
POLICY
}
