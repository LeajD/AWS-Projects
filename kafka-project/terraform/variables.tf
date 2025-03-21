variable region {
    description = "The region name"
    default     = "us-east-1"
}
variable zone1 {
    description = "The 1st availability zone"
    default     = "us-east-1a"
}

variable zone2 {
    description = "The 2nd availability zone"
    default     = "us-east-1b"
}

variable "kafka_connect_role_name" {
  description = "The name of the Kafka Connect role"
  type        = string
  default     = "kafka-connect-role"
}

variable "kafka_connect_policy_name" {
  description = "The name of the Kafka Connect policy"
  type        = string
  default     = "KafkaConnectPolicy"
}

variable "ec2_kafka_role_name" {
  description = "The name of the EC2 Kafka role"
  type        = string
  default     = "EC2KafkaRole"
}

variable "ec2_kafka_policy_name" {
  description = "The name of the EC2 Kafka policy"
  type        = string
  default     = "EC2KafkaPolicy"
}

variable "ec2_kafka_profile_name" {
  description = "The name of the EC2 Kafka instance profile"
  type        = string
  default     = "EC2KafkaProfile"
}

variable "lambda_role_name" {
  description = "Name for the Lambda IAM role"
  type        = string
  default     = "rds-init-lambda-role"
}

variable "lambda_function_name" {
  description = "Name for the Lambda function"
  type        = string
  default     = "init_db"
}



variable "lambda_runtime" {
  description = "The runtime for the Lambda function"
  type        = string
  default     = "python3.8"
}

variable "lambda_timeout" {
  description = "Lambda Function timeout in seconds"
  type        = number
  default     = 60
}

variable "lambda_db_password" {
  description = "Database password for the Lambda. (Preferably load this via Secrets Manager)"
  type        = string
  default     = "test"
}

variable "cloudwatch_event_rule_name" {
  description = "Name for the CloudWatch Event Rule that triggers the Lambda"
  type        = string
  default     = "init-db-trigger"
}

variable "cloudwatch_rule_schedule" {
  description = "Schedule expression for triggering the Lambda"
  type        = string
  default     = "rate(10 minutes)"
}

variable "cloudwatch_event_target_id" {
  description = "Target id for the CloudWatch Event Target"
  type        = string
  default     = "init-db"
}

variable "lambda_permission_statement_id" {
  description = "Statement id for the Lambda permission resource"
  type        = string
  default     = "AllowExecutionFromCloudWatch"
}


variable "msk_security_group_name" {
  description = "Name of the security group for the MSK cluster"
  type        = string
  default     = "msk-cluster-sg"
}



variable "msk_cluster_name" {
  description = "Name of the MSK cluster"
  type        = string
  default     = "my-msk-cluster"
}

variable "kafka_version" {
  description = "Kafka version for the MSK cluster"
  type        = string
  default     = "3.6.0"
}

variable "msk_number_of_broker_nodes" {
  description = "Number of broker nodes in the MSK cluster"
  type        = number
  default     = 2
}

variable "msk_instance_type" {
  description = "Instance type for MSK broker nodes"
  type        = string
  default     = "kafka.t3.small"
}

variable "msk_volume_size" {
  description = "Volume size (in GB) for MSK broker nodes"
  type        = number
  default     = 10
}

variable "msk_environment_tag" {
  description = "Environment tag for the MSK cluster"
  type        = string
  default     = "dev"
}

variable "msk_cluster_tag_name" {
  description = "Name tag for the MSK cluster"
  type        = string
  default     = "msk-provisioned-cluster"
}

variable "connector_sqlserver_name" {
  description = "Name for the connector-sqlserver custom plugin"
  type        = string
  default     = "connector-sqlserver"
}

variable "connector_sqlserver_file_key" {
  description = "S3 file key for the connector-sqlserver plugin zip"
  type        = string
  default     = "connector-sqlserver.zip"
}

variable "kafka_connect_s3_plugin_name" {
  description = "Name for the kafka-connect-s3 custom plugin"
  type        = string
  default     = "kafka-connect-s3"
}

variable "kafka_connect_s3_plugin_file_key" {
  description = "S3 file key for the kafka-connect-s3 plugin zip"
  type        = string
  default     = "kafka-connect-s3.zip"
}


variable "rds_allocated_storage" {
  description = "Allocated storage (in GB) for the RDS instance"
  type        = number
  default     = 20
}

variable "rds_storage_encrypted" {
  description = "Whether the RDS storage is encrypted"
  type        = bool
  default     = true
}

variable "rds_engine" {
  description = "RDS engine name"
  type        = string
  default     = "sqlserver-se"
}
variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.m5.large"
}

variable "rds_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "admin"
}

variable "rds_license_model" {
  description = "License model for the RDS instance"
  type        = string
  default     = "license-included"
}

variable "rds_publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
  default     = false
}

variable "rds_instance_name" {
  description = "Tag value for the RDS instance Name"
  type        = string
  default     = "mssql-sample-db"
}

variable "web_instance_type" {
  description = "EC2 instance type for the management instance"
  type        = string
  default     = "t3.micro"
}

variable "web_subnet_id" {
  description = "Subnet ID for the EC2 instance (typically a public subnet)"
  type        = string
  # Adjust the default or provide via tfvars
  default     = "subnet-0123456789abcdef0"
}

variable "web_instance_name" {
  description = "Tag value for the EC2 instance Name"
  type        = string
  default     = "EC2-Instance"
}
variable "rds_engine_version" {
  description = "Version of the SQL Server engine"
  type        = string
  default     = "15.00.4415.2.v1"
}


variable "bucket_name_prefix" {
  description = "The prefix to use for the S3 bucket name"
  type        = string
  default     = "my-kafka-project-bucket"
}


variable "s3_version_enabled" {
  description = "Enable versioning in the S3 bucket"
  type        = bool
  default     = true
}

variable "connector_sqlserver" {
    description = "Name of the connector-sqlserver plugin"
    type        = string
    default     = "connector-sqlserver"
}
variable "connector_s3" {
    description = "Name of the connector-sqlserver plugin"
    type        = string
    default     = "kafka-connect-s3"
}
variable "db_subnet_group_name" {
  description = "Name for the RDS subnet group"
  type        = string
  default     = "rds-subnets"
}

variable "db_subnet_group_tag" {
  description = "Tag for the RDS subnet group"
  type        = string
  default     = "RDS Subnet Group"
}

variable "db_sg_name" {
  description = "Name of the security group for RDS MSSQL instance"
  type        = string
  default     = "rds-mssql-sg"
}
variable "s3_bucket_name_tag" {
  description = "Tag value for the S3 bucket Name"
  type        = string
  default     = "Kafka Project S3 destination Bucket"
}

variable "environment" {
  description = "Environment tag value"
  type        = string
  default     = "dev"
}

variable "web_sg_name" {
  description = "Name for the security group for EC2 managing RDS"
  type        = string
  default     = "ec2-mssql-sg"
}
variable "kafka_connect_log_group_name" {
  description = "Name for the Kafka Connect CloudWatch log group"
  type        = string
  default     = "/aws/mskconnect/kafka-connectors"
}

variable "kafka_connect_log_group_retention" {
  description = "Retention in days for the Kafka Connect log group"
  type        = number
  default     = 7
}