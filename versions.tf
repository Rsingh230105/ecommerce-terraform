terraform {
  # Minimum Terraform version required by this project.
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      # AWS provider used to create and manage AWS resources.
      source = "hashicorp/aws"

      # Use a modern AWS provider version.
      version = "~> 6.0"
    }
  }
}