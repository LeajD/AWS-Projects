output "api_gateway_id" {
  description = "The ID of the API Gateway."
  value       = aws_api_gateway_rest_api.api_gateway.id
}

output "state_machine_arn" {
  description = "The ARN of the Step Functions state machine."
  value       = aws_sfn_state_machine.state_machine.arn
}

output "sqs_queue_url" {
  description = "The URL of the SQS queue."
  value       = aws_sqs_queue.sqs_queue.url
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic."
  value       = aws_sns_topic.sns_topic.arn
}

output "api_gateway_stage" {
  description = "The name of the deployed API Gateway stage."
  value       = aws_api_gateway_stage.stage.stage_name
}

output "itemshop_check_lambda_arn" {
  description = "The ARN of the Lambda function that checks item shop stock."
  value       = aws_lambda_function.itemshop_check_lambda.arn
}

output "rds_update_lambda_arn" {
  description = "The ARN of the Lambda function that updates RDS with transactional data."
  value       = aws_lambda_function.rds_update_lambda.arn
}

output "itemshop_check_lambda_s3_object_key" {
  description = "The S3 object key for the itemshop check Lambda zip file."
  value       = aws_s3_object.itemshop_check_lambda_zip.key
}

output "rds_ingestion_lambda_s3_object_key" {
  description = "The S3 object key for the RDS ingestion Lambda zip file."
  value       = aws_s3_object.rds_ingestion_lambda_zip.key
}

output "lambda_secrets_policy_arn" {
  description = "The ARN of the Lambda secrets policy."
  value       = aws_iam_policy.lambda_secrets_policy.arn
}


output "lambda_role_arn" {
  description = "ARN of the Lambda execution role."
  value       = aws_iam_role.lambda_role.arn
}

output "step_function_role_arn" {
  description = "ARN of the Step Functions execution role."
  value       = aws_iam_role.step_function_role.arn
}

output "glue_role_arn" {
  description = "ARN of the Glue execution role."
  value       = aws_iam_role.glue_role.arn
}

output "glue_policy_arn" {
  description = "ARN of the Glue policy."
  value       = aws_iam_policy.glue_policy.arn
}

output "lambda_policy_arn" {
  description = "ARN of the Lambda policy."
  value       = aws_iam_policy.lambda_policy.arn
}

output "stepfunctions_start_policy_arn" {
  description = "ARN of the Step Functions start execution policy."
  value       = aws_iam_policy.stepfunctions_start_policy.arn
}

output "stepfunctions_execution_policy_arn" {
  description = "ARN of the Step Functions execution policy."
  value       = aws_iam_policy.stepfunctions_execution_policy.arn
}

output "lambda_rds_policy_arn" {
  description = "ARN of the Lambda RDS policy."
  value       = aws_iam_policy.lambda_rds_policy.arn
}

output "lambda_rds_role_arn" {
  description = "ARN of the Lambda RDS execution role."
  value       = aws_iam_role.lambda_rds_role.arn
}


output "aurora_cluster_id" {
  description = "The Aurora (RDS) Cluster Identifier."
  value       = aws_rds_cluster.aurora_cluster.id
}

output "aurora_cluster_endpoint" {
  description = "The endpoint of the Aurora (RDS) Cluster."
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_cluster_arn" {
  description = "The ARN of the Aurora (RDS) Cluster."
  value       = aws_rds_cluster.aurora_cluster.arn
}

output "redshift_cluster_endpoint" {
  description = "The endpoint of the Redshift Cluster."
  value       = aws_redshift_cluster.redshift_cluster.endpoint
}

output "redshift_cluster_id" {
  description = "The Redshift Cluster Identifier."
  value       = aws_redshift_cluster.redshift_cluster.cluster_identifier
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket used for Glue."
  value       = aws_s3_bucket.my_bucket.bucket
}

output "glue_job_name" {
  description = "The name of the Glue Job for Redshift ingestion."
  value       = aws_glue_job.glue_job_redshfit.name
}

output "glue_connection_name" {
  description = "The name of the Glue connection to Redshift."
  value       = aws_glue_connection.glue_connection.name
}

output "glue_catalog_database" {
  description = "The name of the Glue Catalog Database."
  value       = aws_glue_catalog_database.glue_database.name
}

output "glue_crawler_name" {
  description = "The name of the Glue Crawler."
  value       = aws_glue_crawler.json_crawler.name
}

output "cloudwatch_log_group" {
  description = "The CloudWatch Log Group used for Glue logs."
  value       = aws_cloudwatch_log_group.my_log_group.name
}