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
