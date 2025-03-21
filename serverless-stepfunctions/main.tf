

terraform {
  backend "s3" {
    bucket         = "serverlessproject-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "tf-state-file-lock"
  }
}



resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = var.api_gateway
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

resource "aws_dynamodb_table" "dynamodb_table" {
  name           = var.dynamodb_table
  hash_key       = "item_name"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "item_name"
    type = "S"
  }
}

resource "aws_sqs_queue" "sqs_queue" {
  name = var.sqs_queue
}
resource "aws_sns_topic" "sns_topic" {
  name = var.sns_topic
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "adress@gmail.com"  # Your email address for alerts
}



data "template_file" "sfn-definition" {
  #template = jsonencode(yamldecode(file("step-function-definition.yaml")))
  template = file("${var.stepfunctions}.json")
  vars = {
    lambda_function_arn = aws_lambda_function.itemshop_check_lambda.arn
    rds_lambda_function_arn = aws_lambda_function.rds_update_lambda.arn
    sns_topic_arn = aws_sns_topic.sns_topic.arn
    sqs_queue_url = aws_sqs_queue.sqs_queue.url
  }
}


resource "aws_sfn_state_machine" "state_machine" { #aws_sfn_state_machine
  name     = var.state_machine
  role_arn = aws_iam_role.step_function_role.arn
  definition = data.template_file.sfn-definition.rendered
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type = "AWS" #"AWS_PROXY"
  uri  = "arn:aws:apigateway:${var.region}:states:action/StartExecution"
  credentials = aws_iam_role.step_function_role.arn

    request_templates = {
    "application/json" = <<EOF
{
  "stateMachineArn": "${aws_sfn_state_machine.state_machine.arn}",
  "input": "$util.escapeJavaScript($input.body)"
}
EOF
  }

}



resource "aws_lambda_permission" "api_gateway_lambda_permission" {
  statement_id  = var.api_invoke
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
  function_name = aws_lambda_function.itemshop_check_lambda.function_name
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  description = "Deployment for Serverless Step Functions API"

  # Ensure deployment occurs after all methods/integrations are created
  depends_on = [aws_api_gateway_integration.integration]
}


resource "aws_api_gateway_stage" "stage" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name  = var.api_stage

  variables = {
    stateMachineArn = aws_sfn_state_machine.state_machine.arn
  }
}


resource "aws_api_gateway_method_response" "success_response" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = aws_api_gateway_method.method.http_method
  status_code   = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id       = aws_api_gateway_rest_api.api_gateway.id
  resource_id       = aws_api_gateway_resource.resource.id
  http_method       = aws_api_gateway_method.method.http_method
  status_code       = aws_api_gateway_method_response.success_response.status_code

  response_templates = {
    "application/json" = "$input.body"
  }
}