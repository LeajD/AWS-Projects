resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "example3" {
  bucket = "my-example-bucket3-${random_id.bucket_suffix.hex}"
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Name        = "ExampleS3Bucket"
    Environment = "Test"
  }
}


resource "aws_s3_bucket" "example4" {
  bucket = "my-example-bucket4-${random_id.bucket_suffix.hex}"
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Name        = "ExampleS4Bucket"
    Environment = "Test"
  }
}
resource "aws_s3_bucket" "example5" {
  bucket = "my-example-bucket5-${random_id.bucket_suffix.hex}"
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Name        = "ExampleS4Bucket"
    Environment = "Test"
  }
}
resource "aws_s3_bucket" "example6" {
  bucket = "my-example-bucket6-${random_id.bucket_suffix.hex}"
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Name        = "ExampleS4Bucket"
    Environment = "Test"
  }
}
