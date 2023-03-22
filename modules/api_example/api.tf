resource "aws_cognito_user_pool" "api_pool" {
  name = var.pool_name
}

resource "aws_cognito_user_pool_client" "api_client" {
  name = "API_Example_Key"
  user_pool_id = aws_cognito_user_pool.api_pool.id
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_apigatewayv2_api" "api_implementation" {
  name = "api_implementation"
  protocol_type = var.protocol_type
}

resource "aws_apigatewayv2_authorizer" "api_auth" {
  api_id           = aws_apigatewayv2_api.api_implementation.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.api_client.id]
    issuer   = "https://${aws_cognito_user_pool.api_pool.endpoint}"
  }
}

resource "aws_apigatewayv2_integration" "api_integration" {
  api_id           = aws_apigatewayv2_api.api_implementation.id
  integration_type = "AWS_PROXY"
  connection_type = "INTERNET"
  integration_method = "POST"
  integration_uri = "arn:aws:apigateway:us-east-2:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-2:703866956858:function:API_Implementation/invocations"
}

resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.api_implementation.id
  route_key = "GET /test"
  target = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.api_auth.id
}

resource "aws_apigatewayv2_deployment" "api_deployment" {
  api_id      = aws_apigatewayv2_api.api_implementation.id
  description = "Dev"
  depends_on = [
    aws_apigatewayv2_route.api_route
  ]
  lifecycle {
    create_before_destroy = true
  }
}


