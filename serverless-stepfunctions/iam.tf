data "aws_caller_identity" "current" {} #provides account ID


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
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "states.amazonaws.com"
        },
        Action = "sts:AssumeRole"
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
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow",
        Resource = [
            "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.itemshop_check_lambda}",
            "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.rds_put_lambda}"
        ]
      },
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
        ],
        Effect = "Allow",
        Resource = [
            "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.itemshop_check_lambda}"
        ]
      },
      {
        Action = [
          "sqs:SendMessage"
        ]
        Effect   = "Allow",
        Resource = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_sqs_queue.sqs_queue.name}"
      },
      {
        Action = [
          "sns:Publish"
        ],
        Effect = "Allow",
        Resource = [
            "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic}"
        ]
      },
      {
        Action = [
              "secretsmanager:GetSecretValue"
        ],
        Effect = "Allow",
        Resource = [
            "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${data.aws_secretsmanager_secret.redshift_secret.name}",
            "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${data.aws_secretsmanager_secret.rds_secret.name}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances"
          // Add "rds-db:connect" if using RDS IAM authentication
        ],
        Resource = "arn:aws:rds:${var.region}:${data.aws_caller_identity.current.account_id}:cluster:${var.aurora_cluster_name}"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "LambdaPolicyAttachment"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.lambda_role.name]
}



resource "aws_iam_policy" "stepfunctions_start_policy" {
  name        = "StepFunctionsStartExecutionPolicy"
  description = "Policy to allow Step Functions StartExecution on MyStateMachine"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "states:StartExecution",
        Resource = "${aws_sfn_state_machine.state_machine.arn}"
      }
    ]
  })
}




resource "aws_iam_policy" "stepfunctions_execution_policy" {
  name        = "StepFunctionsExecutionRole"
  description = "Policy to allow Step Functions execute other aws services - lambda,dynamodb,sns"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Action = [
                "lambda:InvokeFunction",
                "dynamodb:PutItem",
                "sns:Publish",
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes",
                "glue:StartJobRun",
                "glue:GetJobRun",
                "glue:GetJobRuns",
                "glue:GetJob",
                "glue:BatchStopJobRun"
            ],
            Effect = "Allow",
            Resource = "arn:aws:states:${var.region}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.state_machine}"
        },
        {
            Effect = "Allow",
            Action = [
              "glue:StartJobRun",
               "glue:GetJobRuns"
            ],
            Resource = "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:job/${var.glue_job_redshift_name}"
        },
        {
            Effect = "Allow",
            Action = [
                "sqs:SendMessage"
            ],
          Resource = "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_sqs_queue.sqs_queue.name}"
        },
        {
            Effect = "Allow",
            Action = [
                "s3:PutObject"
            ],
            Resource = "arn:aws:s3:::${var.bucket_glue}/*"
        },
        {
            Action = [
                "lambda:InvokeFunction"
            ],
            Effect = "Allow",
            Resource = [
                "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.itemshop_check_lambda}",
                "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.rds_put_lambda}"
            ]
        },
        {
            Action = [
                "secretsmanager:GetSecretValue"
            ],
            Effect = "Allow",
            Resource = [
                "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${data.aws_secretsmanager_secret.redshift_secret.name}",
                "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${data.aws_secretsmanager_secret.rds_secret.name}"
            ]
        },
        {
            Effect = "Allow",
            Action = [
                "sns:Publish"
            ],
            Resource = "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:NotificationTopic:${var.sns_topic}"
        },
        {
            Effect = "Allow",
            Action = [
                "glue:StartJobRun",
                "glue:GetJob",
                "glue:GetJobRuns"
            ],
            Resource = "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:job/${var.glue_job_redshift_name}"
        }
    ],
    Version = "2012-10-17"
})
}

resource "aws_iam_role_policy_attachment" "attach_stepfunctions_policy" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.stepfunctions_start_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_stepfunctions_execute_policy" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.stepfunctions_execution_policy.arn
}



#Glue:
resource "aws_iam_role" "glue_role" {
  name = "AWSGlueStepFunctionsRedshiftRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}



resource "aws_iam_policy" "glue_policy" {
  name        = "AWSGlueStepFunctionsRedshiftPolicy" #policy for Glue to make last stages of stepfunction work
  description = "IAM policy for AWS Glue job to process data from Step Functions and ingest into Redshift"

  policy = jsonencode({
    Statement = [
        {
            Action = [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            Effect = "Allow",
            Resource = [
                "arn:aws:s3:::my-stepfunctions-data-bucket",
                "arn:aws:s3:::my-stepfunctions-data-bucket/*",
                "arn:aws:s3:::${var.bucket_glue}",
                "arn:aws:s3:::${var.bucket_glue}/*"
            ]
        },
        {
            Action = [
                "glue:*"
            ],
            Effect = "Allow",
            Resource = "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:job/${var.glue_job_redshift_name}"
        },
        {
            Action = [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            Effect = "Allow",
            Resource= "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            Action= [
                "states:DescribeExecution",
                "states:GetExecutionHistory"
            ],
            Effect = "Allow",
            Resource = "arn:aws:states:${var.region}:${data.aws_caller_identity.current.account_id}:stateMachine:${var.state_machine}"
        },
        {
            Action = [
                "redshift:DescribeClusters",
                "redshift:GetClusterCredentials",
                "redshift:ExecuteStatement"
            ],
            Effect = "Allow",
            Resource = "${aws_redshift_cluster.redshift_cluster.arn}"
        },
        {
            Action = [
                "secretsmanager:GetSecretValue"
            ],
            Effect = "Allow",
            Resource = [
                "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${data.aws_secretsmanager_secret.redshift_secret.name}",
                "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${data.aws_secretsmanager_secret.rds_secret.name}"
            ]
        }
    ],
    Version = "2012-10-17"
    })
  }

resource "aws_iam_role_policy_attachment" "attach_glue_execute_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}



resource "aws_iam_policy" "lambda_rds_policy" {
  name        = "LambdaRdsPolicy"
  description = "Policy to allow Lambda to retrieve the RDS secret and execute statements via RDS Data API."
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action =  [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:${var.region}:*:secret:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_rds_policy_attach" {
  role       = aws_iam_role.lambda_rds_role.name
  policy_arn = aws_iam_policy.lambda_rds_policy.arn
}

resource "aws_iam_role" "lambda_rds_role" {
  name = "LambdaRDSExecutionRole"
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
