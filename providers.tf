terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# configure AWS provider
provider "aws" {
  region = "eu-west-3"
}