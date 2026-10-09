variable "project_name" {
  description = "Project name used in log group names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name used in log group names and tags"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain service logs"
  type        = number
  default     = 7
}
