resource "aws_apigatewayv2_api" "api" {
  name          = format("%s-api", var.composite_name)
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
  name   = var.stage_name
}

resource "aws_cognito_user_pool" "user_pool" {
  name                     = format("%s-user-pool", var.composite_name)
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  mfa_configuration = "OFF"

  lifecycle {
    ignore_changes = [
      lambda_config,
    ]
  }

  schema {
    attribute_data_type = "String"
    mutable             = true
    name                = "role_ids"
    string_attribute_constraints {
      min_length = 0
      max_length = 1024
    }
  }
}

resource "aws_cognito_user_pool_client" "users_pool_client" {
  name                   = format("%s-users-pool-app-client", var.composite_name)
  generate_secret        = false
  access_token_validity  = 120 # Two hours validity
  refresh_token_validity = 7   # One week validity
  user_pool_id           = aws_cognito_user_pool.user_pool.id
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
  token_validity_units {
    access_token = "minutes"
  }
}
resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id          = aws_apigatewayv2_api.api.id
  authorizer_type = "JWT"
  name            = "AdminAuthorizer"
  identity_sources = [
    "$request.header.authorization",
  ]

  jwt_configuration {
    audience = [
      aws_cognito_user_pool_client.users_pool_client.id,
    ]
    issuer = format(
      "https://cognito-idp.%s.amazonaws.com/%s",
      var.aws_region,
      aws_cognito_user_pool.user_pool.id
    )
  }
}

resource "random_password" "password" {
  length  = 24
  special = false
}

resource "aws_db_instance" "psql_db" {
  allocated_storage               = 20
  apply_immediately               = true
  engine                          = "postgres"
  engine_version                  = 12.8
  identifier_prefix               = format("%s-", var.composite_name)
  instance_class                  = "db.t2.micro"
  name                            = format("%s%sdb", replace(var.project_name, "-", ""), var.stage_name)
  password                        = random_password.password.result
  port                            = 5432
  publicly_accessible             = true
  storage_type                    = "gp2"
  username                        = format("%s_root", replace(var.composite_name, "-", "_"))
  security_group_names            = []
  tags                            = {}
  enabled_cloudwatch_logs_exports = []
  skip_final_snapshot             = true
  backup_retention_period         = 0
  depends_on = [
    random_password.password
  ]
}

output "db_pwd" {
  value       = aws_db_instance.psql_db.password
  description = "DB Password, save this in a safe place"
  depends_on = [
    aws_db_instance.psql_db
  ]
  sensitive = true
}

output "api_gateway_id" {
  value       = aws_apigatewayv2_api.api.id
  description = "API Gateway id"
}

output "api_gateway_authorizer_id" {
  value       = aws_apigatewayv2_authorizer.cognito_authorizer.id
  description = "API Gateway authorizer id"
}

