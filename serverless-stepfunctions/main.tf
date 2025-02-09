provider "aws" {
  region = "us-west-2"
}

resource "aws_lambda_function" "data_processor_lambda" {
  function_name = "DataProcessorLambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.8"
  filename      = "lambda_function.zip"  # Upload your Lambda code here
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "StepFunctionsAPI"
  description = "API Gateway to trigger Step Functions workflow"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "trigger"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_dynamodb_table" "dynamo_table" {
  name           = "DataTable"
  hash_key       = "id"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "ErrorQueue"
}

resource "aws_sns_topic" "sns_topic" {
  name = "NotificationTopic"
}


data "template_file" "sfn-definition" {
  #template = jsonencode(yamldecode(file("step-function-definition.yaml")))
  template = file("step-function-definition.yaml")
}


resource "aws_stepfunctions_state_machine" "state_machine" { #aws_sfn_state_machine
  name     = "MyStateMachine"
  role_arn = aws_iam_role.step_function_role.arn
  definition = data.template_file.sfn-definition.rendered


resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri  = "arn:aws:apigateway:${var.region}:states:action/StartExecution"
  credentials = aws_iam_role.step_function_role.arn
}

resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
  function_name = aws_lambda_function.data_processor_lambda.function_name
}
