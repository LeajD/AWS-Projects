resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "kafka_bucket" {
  bucket = "${var.bucket_name_prefix}-${random_id.bucket_id.hex}"
  acl    = var.s3_acl

  versioning {
    enabled = var.s3_versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.s3_sse_algorithm
      }
    }
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_block" {
  bucket = aws_s3_bucket.kafka_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

