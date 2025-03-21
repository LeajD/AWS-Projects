output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block associated with the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway for the VPC"
  value       = aws_internet_gateway.igw.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private.id, aws_subnet.private2.id]
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public1.id
}

output "db_instance_endpoint" {
  description = "RDS MSSQL instance endpoint address"
  value       = aws_db_instance.mssql.address
}

output "db_instance_port" {
  description = "RDS MSSQL instance port"
  value       = aws_db_instance.mssql.port
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Kafka connectors"
  value       = aws_s3_bucket.kafka_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Kafka connectors"
  value       = aws_s3_bucket.kafka_bucket.arn
}

output "msk_cluster_arn" {
  description = "ARN of the MSK Cluster"
  value       = aws_msk_cluster.provisioned_cluster.arn
}

output "msk_cluster_bootstrap_brokers" {
  description = "Bootstrap brokers for the MSK Cluster"
  value       = aws_msk_cluster.provisioned_cluster.bootstrap_brokers
}

output "kafka_connect_role_arn" {
  description = "ARN of the Kafka Connect IAM role"
  value       = aws_iam_role.kafka_connect_role.arn
}

output "ec2_kafka_role_arn" {
  description = "ARN of the EC2 Kafka IAM role"
  value       = aws_iam_role.ec2_kafka_role.arn
}

output "ec2_kafka_instance_profile" {
  description = "Name of the EC2 Kafka instance profile"
  value       = aws_iam_instance_profile.ec2_kafka_profile.name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.init_db.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}