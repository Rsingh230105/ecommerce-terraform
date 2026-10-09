variable "project_name" {
  description = "Project name used in repository names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name used in repository names and tags"
  type        = string
}

variable "force_delete" {
  description = "Allow repository deletion when images are present"
  type        = bool
  default     = false
}
