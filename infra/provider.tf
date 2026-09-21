terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "std12-ex8-tot-s3"
    key            = "ex8-tot/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "std12-ex8-tot-tf-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = { Class = "bipa17" }
  }
}
