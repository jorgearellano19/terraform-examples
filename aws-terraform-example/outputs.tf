
output "db_pwd" {
  value       =  module.api.db_pwd
  description = "DB Password, save this in a safe place"
  sensitive = true
}

output "api_gateway_id" {
  value       = module.api.api_gateway_id
  description = "API Gateway id"
}

output "api_gateway_authorizer_id" {
  value       = module.api.api_gateway_authorizer_id
  description = "API Gateway authorizer id"
}

# output "bucket_name" {
#   value = module.app.aws_s3_bucket.frontend_build.id
# }

# output "cloudfront_endpoint" {
#   value = module.app.aws_cloudfront_distribution.cloudfront_frontend.domain_name
# }
