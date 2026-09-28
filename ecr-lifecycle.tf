resource "aws_ecr_lifecycle_policy" "product_service" {
  repository = aws_ecr_repository.product_service.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images older than 7 days"

        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }

        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only the latest 20 versioned images"

        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 20
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}