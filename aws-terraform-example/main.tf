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


// Frontend stuff. S3 Bucket with Cloudfront distribution
resource "aws_s3_bucket" "frontend_build" {
  bucket = "front-build"
  tags = {
    "Name" = "Frontend build bucket"
  }
}

resource "aws_s3_bucket_acl" "frontend_build_acl" {
  bucket = aws_s3_bucket.frontend_build.id
  acl    = "private"
}

resource "aws_cloudfront_origin_access_identity" "frontend_oai" {
  comment = "OAI for private bucket."
}

resource "aws_cloudfront_distribution" "cloudfront_frontend" {

  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket.frontend_build.bucket_domain_name
    origin_id   = var.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.frontend_oai.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }

  }


  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.origin_id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}

resource "aws_apigatewayv2_api" "api" {
  name          = "example-http-api"
  protocol_type = "HTTP"
  description   = "Api Gateway description example"
  cors_configuration {
    allow_origins = ["*"]
    allow_headers = [
      "Content-Type",
      "X-Amz-Date",
      "Authorization",
      "X-Api-Key",
      "X-Amz-Security-Token",
      "X-Amz-User-Agent",
      "Access-Control-Allow-Origin",
      "Accept",
      "AuthRefreshToken",
      "X-AuthRefreshToken",
    ]
    allow_methods = [
      "GET",
      "OPTIONS",
      "POST",
      "PUT",
      "DELETE",
      "PATCH",
    ]
  }
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id = aws_apigatewayv2_api.api.id
  name   = "example-stage"
}
