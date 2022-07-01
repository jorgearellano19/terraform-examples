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

locals {
  composite_name = format("%s-%s", var.project_name, var.stage_name)
  client_cdn_origin_id = format("%s-client-cdn-origin", local.composite_name)
  composite_name_upper = format("%s", upper(replace(local.composite_name, "-", "_")))
}