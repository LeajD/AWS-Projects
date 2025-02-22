resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "example" {
  bucket = "my-example-bucket-${random_id.bucket_suffix.hex}"
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Name        = "ExampleS3Bucket"
    Environment = "Test"
  }
}