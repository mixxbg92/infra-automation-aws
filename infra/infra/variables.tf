variable "project" {
  description = "Project name prefix"
  type        = string
  default     = "hristo-rusev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "db_username" {
  description = "DB username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "DB password"
  type        = string
  sensitive   = true
}
