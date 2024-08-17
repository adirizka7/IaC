data "archive_file" "lambda" {
  type        = "zip"
  source_file = "pybase/main.py"
  output_path = "pybase/main.zip"
}

resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda.output_path
  function_name = local.function_name
  role          = aws_iam_role.lambda.arn
  handler       = "main.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = local.python_version
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}
