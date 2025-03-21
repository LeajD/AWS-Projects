resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "kafka_bucket" {
  bucket = "${var.bucket_name_prefix}-${random_id.bucket_id.hex}"
  acl    = "private"

  versioning {
    enabled = var.s3_version_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = var.s3_bucket_name_tag
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "kafka_bucket" {
  bucket = aws_s3_bucket.kafka_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create the S3 Gateway Endpoint for Kafka to connect
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  #route_table_ids = data.aws_route_tables.vpc_route_tables.ids

  tags = {
    Name = "S3 Endpoint for ${aws_vpc.main.id}"
  }
}

resource "aws_s3_bucket_object" "connector_sqlserver_zip" {
  bucket = aws_s3_bucket.kafka_bucket.bucket
  key    = "${var.connector_sqlserver}.zip"
  source = "../connectors/${var.connector_sqlserver}.zip"
  etag   = filemd5("../connectors/${var.connector_sqlserver}.zip")

  depends_on = [ aws_s3_bucket.kafka_bucket ]
}

resource "aws_s3_bucket_object" "connector_s3_zip" {
  bucket = aws_s3_bucket.kafka_bucket.id
  key    = "${var.connector_s3}.zip"
  source = "../connectors/${var.connector_s3}.zip"
  etag   = filemd5("../connectors/${var.connector_s3}.zip")

  depends_on = [ aws_s3_bucket.kafka_bucket ]
}