terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "infra-automation-state-hristo" # your bucket name
    key            = "terraform/infra.tfstate"       # path inside the bucket
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks" # for state locking
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
