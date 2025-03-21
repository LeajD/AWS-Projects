# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# (Optionally, add policies that grant connectivity or secrets read access)

# Lambda Function to initialize the RDS database
resource "aws_lambda_function" "init_db" {
  function_name = var.lambda_function_name
  filename      = "${var.lambda_function_name}.zip"      # Your zipped Lambda code package
  handler       = "${var.lambda_function_name}.lambda_handler"
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_role.arn
  timeout       = var.lambda_timeout

  # VPC configuration to allow Lambda to connect to your private RDS instance.
  vpc_config {
    subnet_ids         = [ aws_subnet.private.id, aws_subnet.private2.id ]
    security_group_ids = [ aws_security_group.db_sg.id ]
  }

  environment {
    variables = {
      DB_HOST     = aws_db_instance.mssql.address
      DB_PORT     = aws_db_instance.mssql.port
      DB_USER     = aws_db_instance.mssql.username
      DB_NAME     = aws_db_instance.mssql.address      
      # It's recommended to pull the password from Secrets Manager.
      DB_PASSWORD = "test" #jsondecode(data.aws_secretsmanager_secret_version.rds_secret.secret_string)["password"]
    }
  }
}

# CloudWatch Event Rule that triggers the Lambda function periodically (e.g., every 10 minutes)
resource "aws_cloudwatch_event_rule" "init_db_rule" {
  name                = var.cloudwatch_event_rule_name
  schedule_expression = var.cloudwatch_rule_schedule
}

resource "aws_cloudwatch_event_target" "init_db_target" {
  rule = aws_cloudwatch_event_rule.init_db_rule.name
  arn  = aws_lambda_function.init_db.arn
  target_id = var.cloudwatch_event_target_id
}

# Grant CloudWatch Events permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = var.lambda_permission_statement_id
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.init_db.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.init_db_rule.arn
}