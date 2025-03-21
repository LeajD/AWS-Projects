
data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "../networking/terraform.tfstate"
  }
}

resource "aws_s3_object" "itemshop_check_lambda_zip" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "${var.itemshop_check_lambda}.zip"
  source = "lambda/${var.itemshop_check_lambda}.zip" # Update to your local file path.
  etag   = filemd5("lambda/${var.rds_put_lambda}.zip") # Ensures object is updated on file change.
}

resource "aws_s3_object" "rds_ingestion_lambda_zip" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "${var.rds_put_lambda}.zip"
  source = "lambda/${var.rds_put_lambda}.zip" # Update to your local file path.
  etag   = filemd5("lambda/${var.rds_put_lambda}.zip") # Ensures object is updated on file change.
}

#lambda to check itemshop stock
resource "aws_lambda_function" "itemshop_check_lambda" {
  function_name = var.itemshop_check_lambda
  runtime       = "python3.9"
  handler       = "${var.itemshop_check_lambda}.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda/${var.itemshop_check_lambda}.zip"  # Upload your Lambda code here
  timeout       = 120  # Timeout in seconds

  environment {
    variables = {
      #DynamoDB_TABLE = var.dynamodb_table
      secret_name = "${data.aws_secretsmanager_secret.rds_secret.name}"
      region_name = var.region
      DB_HOST = aws_rds_cluster.aurora_cluster.endpoint #check if proper url
      DB_NAME = var.rds_dbname
      DB_USER = var.rds_username
    }
  }
}


#lambda to update rds with transactional data
resource "aws_lambda_function" "rds_update_lambda" {
  function_name = var.rds_put_lambda
  runtime       = "python3.9"
  handler       = "${var.rds_put_lambda}.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda/${var.rds_put_lambda}.zip"  # Upload your Lambda code here
  timeout       = 120  # Timeout in seconds

  environment {
    variables = {
      secret_name = "${data.aws_secretsmanager_secret.rds_secret.name}"
      region_name = var.region
      DB_HOST = aws_rds_cluster.aurora_cluster.endpoint
      DB_NAME = var.rds_dbname
      DB_USER = var.rds_username
    }
  }
}


#give lambda permission to get secret from secret manager in function get_secret()
resource "aws_iam_policy" "lambda_secrets_policy" {
  name   = var.LambdaSecretsManagerPolicy
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["secretsmanager:GetSecretValue"],
        Effect = "Allow",
        Resource =  "${aws_rds_cluster.aurora_cluster.master_user_secret[0].secret_arn}" 
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secrets_policy.arn
}