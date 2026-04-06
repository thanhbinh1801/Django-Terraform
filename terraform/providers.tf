terraform {
  cloud {
    organization = "django-terraform"

    workspaces {
      name = "deploy-python-web"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
