

variable "region" {
  description = "region name"
  type        = string
  default     = "us-east-1"
}


variable "environment" {
  description = "environment name for tags"
  type        = string
  default     = "dev"
}





variable "rds_put_lambda" {
  description = "lambda name that updates rds"
  type        = string
  default     = "RDSIngestionLambda"
}

variable "itemshop_check_lambda" {
  description = "itemshop_check_lambda name"
  type        = string
  default     = "ItemshopCheckLambda" #"DynamoCheckStock"
}


variable "api_gateway" {
  description = "api_gateway name"
  type        = string
  default     = "StepFunctionsAPI"
}

variable "dynamodb_table" {
  description = "dynamdb_table name"
  type        = string
  default     = "DynamoCheckStock"
}

variable "sqs_queue" {
  description = "sqs_queue name"
  type        = string
  default     = "dead-letter-queue"
}

variable "sns_topic" {
  description = "sns_topic name"
  type        = string
  default     = "NotificationTopic"
}

variable "state_machine" {
  description = "stepfunction state_machine name"
  type        = string
  default     = "MyStateMachineProd"
}

variable "stepfunctions" {
  description = "stepfunctions file name"
  type        = string
  default     = "stepfunctions"
}


variable "api_stage" {
  description = "API Gateway deployment stage name"
  type        = string
  default     = "dev"
}

variable "catalog_table" {
  description = "catalog table to store json"
  type        = string
  default     = "jsonfroms3"
}

variable "glue_database" {
  description = "rds_username"
  type        = string
  default     = "rdsuserkikowpio"
}


variable "rds_username" {
  description = "rds username"
  type        = string
  default     = "rdsuserkikowpio"
}

variable "redshift_cluster" {
  description = "redshift cluster name"
  type        = string
  default     = "redshift-cluster"
}
variable "redshift_db" {
  description = "redshift_db name"
  type        = string
  default     = "mydb"
}


variable "glue_connection" {
  description = "glue connection to redshift"
  type        = string
  default     = "glueredshift"
}
variable "redshift_size" {
  description = "redshift node size"
  type        = string
  default     = "dc2.large"
}

variable "rds_instance_size" {
  description = "size for rds instance"
  type        = string
  default     = "default.mysql8.0"
}

variable "rds_dbname" {
  description = "name for rds instance"
  type        = string
  default     = "rdstransactions"
}


variable "glue_job_redshift_name" {
  description = "glue_job_redshift_name"
  type        = string
  default     = "glue-redshift-ingest"
}
variable "bucket_glue" {
  description = "name for bucket storing glue script"
  type        = string
  default     = "gluebucketscript"
}

variable "glue_log_group" {
  description = "name for log group storing aws glue logs"
  type        = string
  default     = "/aws/glue/my-glue-log-group"
}




variable "glue_catalog_db" {
  description = "name for catalog db for glue"
  type        = string
  default     = "jsons3"
}

variable "glue_crawler" {
  description = "name for glue crawler"
  type        = string
  default     = "jsons3-crawler"
}
variable "api_invoke" {
  default = "AllowAPIGatewayInvoke"   # Stage name for API Gateway
  description = "name for aws_lambda_permission to invoke api"
}

variable "LambdaSecretsManagerPolicy" {
  description = "Lambda Secrets Manager Policy"
  type        = string
  default     = "LambdaSecretsManagerPolicy"
  
}

variable "aws_glue_name" {
  default =  "aws-glue-redshift"
  description = "name for aws-glue to ingest data into redshift"
}

variable "AWSGlueServiceRole" {
  default = "AWSGlueServiceRole"
  description = "name for the Glue service role"
}

variable "GlueS3AccessPolicy" {
  default =  "GlueS3AccessPolicy"
  description = "name for glue access policy"
}



variable "aurora_version" {
  default = "8.0.mysql_aurora.3.04.0"
  description = "aurora mysql version"
}


variable "aurora_cluster_name" {
  description = "Aurora cluster name"
  type        = string
  default     = "testauroramysql"  
}