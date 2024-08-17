resource "aws_api_gateway_rest_api" "api" {
  name = "${local.function_name}APIGateway"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "convert"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.resource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST" # Lambda function can only be invoked via POST.
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.resource.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "production"
}

resource "aws_api_gateway_usage_plan" "production" {
  name = "${local.function_name}UsagePlan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.production.stage_name
  }

  quota_settings {
    limit  = 100
    offset = 0
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_api_key" "production" {
  name = "${local.function_name}APIKey"
}

resource "aws_api_gateway_usage_plan_key" "production" {
  key_id        = aws_api_gateway_api_key.production.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.production.id
}
