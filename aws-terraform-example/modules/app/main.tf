// Frontend stuff. S3 Bucket with Cloudfront distribution
resource "aws_s3_bucket" "frontend_build" {
  bucket = format("%s-client-build", var.composite_name)
  tags = {
    "Name" = "Frontend build bucket"
  }
}

resource "aws_s3_bucket_acl" "frontend_build_acl" {
  bucket = aws_s3_bucket.frontend_build.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "frontend_build_bucket_policy" {
  bucket = aws_s3_bucket.frontend_build.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "frontend_build_publick_access_block" {
  bucket = aws_s3_bucket.frontend_build.id
  block_public_acls       = true
  block_public_policy     = true
}

resource "aws_cloudfront_origin_access_identity" "frontend_oai" {
  comment = "OAI for private bucket."
}

resource "aws_cloudfront_distribution" "cloudfront_frontend" {

  enabled         = true
  is_ipv6_enabled = true
  default_root_object = "index.html" 
  origin {
    domain_name = aws_s3_bucket.frontend_build.bucket_domain_name
    origin_id   = var.client_cdn_origin_id

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
    target_origin_id = var.client_cdn_origin_id
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