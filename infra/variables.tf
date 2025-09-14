variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "iac-web-stack"
}


variable "aws_region" {
  description = "AWS region to deploy"
  type        = string
  default     = "eu-central-1"
}


variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}


variable "public_subnets" {
  description = "CIDRs for public subnets across 2 AZs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "private_subnets" {
  description = "CIDRs for private subnets across 2 AZs"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}


variable "ssh_cidr" {
  description = "CIDR (e.g., your_ip/32) allowed to SSH to EC2"
  type        = string
  default     = "0.0.0.0/0" # For demo only. Replace with your_ip/32.
}


#variable "key_pair_name" {
#  description = "Name for the AWS Key Pair"
#  type        = string
#}


#variable "public_key" {
#  description = "Your SSH public key content"
#  type        = string
#}


variable "instance_type" {
  type    = string
  default = "t3.micro"
}


variable "asg_min" {
  type    = number
  default = 2
}


variable "asg_desired" {
  type    = number
  default = 2
}


variable "asg_max" {
  type    = number
  default = 4
}


variable "db_name" {
  type    = string
  default = "appdb"
}


variable "db_username" {
  type    = string
  default = "appuser"
}


variable "db_password" {
  description = "DB password (do NOT commit real value)"
  type        = string
  sensitive   = true
}


variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}


variable "db_allocated_storage" {
  type    = number
  default = 20
}