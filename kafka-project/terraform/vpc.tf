
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${aws_vpc.main.name}"
  }
}

data "aws_caller_identity" "current" {}


# Data source for private subnets 
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.zone1

  tags = {
    "Name"  = "vpc-private-${var.zone1}"
  }
}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = var.zone2

  tags = {
    "Name"  = "vpc-private-${var.zone2}"
  }
}



resource "aws_db_subnet_group" "rds_subnets" {
  name       = var.db_subnet_group_name
  subnet_ids = [ aws_subnet.private.id, aws_subnet.private2.id ]

  tags = {
    Name = var.db_subnet_group_tag
  }
}

resource "aws_security_group" "db_sg" {
  name        = var.db_sg_name
  description = "Security group for RDS MSSQL instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 1433 #port to connect to rds db
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # adjust this to your allowed CIDR range - 1)kafka IP and 2) your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${aws_internet_gateway.igw.name}"
  }
}
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.zone1

  tags = {
    "Name"  = "vpc-public-${var.zone2}"
  }
}
# Create a public route table for the VPC
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate the public subnets with the public route table
resource "aws_route_table_association" "public_assoc" {
  #for_each      = toset(var.public_subnet_ids) -> then "each.value" in subnet_id
  subnet_id     = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web_sg" {
  name        = var.web_sg_name
  description = "Security group for EC2 to manage RDS MSSQL instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0 
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # adjust this to your allowed CIDR range - 1)kafka IP and 2) your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_cloudwatch_log_group" "kafka_connect_log_group" {
  name              = var.kafka_connect_log_group_name
  retention_in_days = var.kafka_connect_log_group_retention
}
