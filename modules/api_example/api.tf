resource "aws_api_gateway_rest_api" "API" {
  name        = "API"
  description = "This is my API for demonstration purposes"
}

resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  parent_id   = aws_api_gateway_rest_api.API.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_resource" "combination" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "combination"
}

resource "aws_api_gateway_resource" "num" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  parent_id   = aws_api_gateway_resource.combination.id
  path_part   = "{num}"
}

resource "aws_api_gateway_authorizer" "api_authorizer" {
  name            = "cognito-authorizer"
  type            = "COGNITO_USER_POOLS"
  rest_api_id     = aws_api_gateway_rest_api.API.id
  provider_arns   = [aws_cognito_user_pool.api_pool.arn]
  identity_source = "method.request.header.Authorization"
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.API.id
  resource_id   = aws_api_gateway_resource.num.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.api_authorizer.id
  request_parameters = {
    "method.request.path.num" = true
  }
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.API.id
  resource_id             = aws_api_gateway_resource.num.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.expected_api_function.invoke_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  cache_key_parameters    = []
  request_parameters = {
    "integration.request.path.id" = "method.request.path.num"
  }
  request_templates = {
    "application/json" = <<EOF
{
   "combination": "$input.params('num')"
}
EOF
  }
}


# No Authorization

resource "aws_api_gateway_resource" "noauth_combination" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  parent_id   = aws_api_gateway_rest_api.API.root_resource_id
  path_part   = "combination"
}

resource "aws_api_gateway_resource" "noauth_num" {
  rest_api_id = aws_api_gateway_rest_api.API.id
  parent_id   = aws_api_gateway_resource.noauth_combination.id
  path_part   = "{num}"
}

resource "aws_api_gateway_method" "noauth_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.API.id
  resource_id   = aws_api_gateway_resource.noauth_num.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.num" = true
  }
}


resource "aws_api_gateway_integration" "noauth_integration" {
  rest_api_id             = aws_api_gateway_rest_api.API.id
  resource_id             = aws_api_gateway_resource.noauth_num.id
  http_method             = aws_api_gateway_method.noauth_get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.expected_api_function.invoke_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  cache_key_parameters    = []
  request_parameters = {
    "integration.request.path.id" = "method.request.path.num"
  }
  request_templates = {
    "application/json" = <<EOF
{
   "combination": "$input.params('num')"
}
EOF
  }
}
