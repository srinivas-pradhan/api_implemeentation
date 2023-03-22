resource "aws_cognito_user_pool" "api_pool" {
  name = var.pool_name
}

resource "aws_cognito_user_pool_client" "api_client" {
  name         = "API_Example_Key"
  user_pool_id = aws_cognito_user_pool.api_pool.id
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}




