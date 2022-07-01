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

//TODO: Cognito and DB 
