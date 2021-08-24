terraform {
  required_version = ">= 1.0.5"

  backend "s3" {
    encrypt        = true
    bucket         = "terraform-state"
    region         = "us-east-1"
    key            = "k3s/terraform.tfstate"
    acl            = "bucket-owner-full-control"
    dynamodb_table = "terraform-locks"
  }

  required_providers {
    aws        = "= 3.54.0"
    local      = "= 2.1.0"
    null       = "= 3.1.0"
    template   = "= 2.2.0"
    random     = "= 3.1.0"
    kubernetes = "= 2.4.1"
  }
}

provider "aws" {
  region = var.region
}