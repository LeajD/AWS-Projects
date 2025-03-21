variable "aws_region" {
  description = "region to create resources"
  type        = string
  default     = "us-east-1"
}


variable "vpc_cidr" {
  description = "CIDR range for vpc"
  type        = string
  default     = "10.0.0.0/16"
}
variable "project_name" {
  description = "project name"
  type        = string
  default     = "project-networking"
}
variable "environment" {
  description = "environment to deploy infrastructure"
  type        = string
  default     = "dev"
}
variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true #true
}
