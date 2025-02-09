resource "aws_iam_role" "lambda_role" {
  name = "LambdaExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role" "step_function_role" {
  name = "StepFunctionsExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "LambdaExecutionPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "sns:Publish",
          "sqs:SendMessage"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "LambdaPolicyAttachment"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.lambda_role.name]
}
