variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "terraform-vpc"
}

variable "igw_name" {
  description = "Name for the Internet Gateway"
  type        = string
  default     = "terraform-vpc-igw"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "zone1" {
  description = "Primary availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet_name" {
  description = "Name for the public subnet"
  type        = string
  default     = "tf-public-subnet"
}

variable "public_route_table_name" {
  description = "Name for the public route table"
  type        = string
  default     = "tf-public-route-table"
}


variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "kafka-bucket"
}

variable "s3_acl" {
  description = "ACL for the S3 bucket"
  type        = string
  default     = "private"
}

variable "s3_versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_sse_algorithm" {
  description = "S3 server-side encryption algorithm"
  type        = string
  default     = "AES256"
}



variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}




variable "web_instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "web_sg_id" {
  description = "Security group ID for the EC2 instance"
  type        = string
  default     = "allow-customip-sg"  // Update this with your security group ID
}

variable "web_instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "web-instance"
}

variable "jenkins_instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "jenkins-runner"
}