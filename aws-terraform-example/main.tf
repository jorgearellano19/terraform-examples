terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_s3_bucket" "frontend_build" {
  bucket = "front-build"
  tags = {
    "Name" = "Frontend build bucket"
  }
}

resource "aws_s3_bucket_acl" "frontend_build" {
  bucket = aws_s3_bucket.frontend_build.id
  acl = "private"
}
