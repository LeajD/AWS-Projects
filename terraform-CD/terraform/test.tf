resource "random_id" "bucket_suffix" {
  byte_length = 4
}


resource "aws_s3_bucket" "example9" {
  bucket = "my-example-bucket9-${random_id.bucket_suffix.hex}"
  acl    = "private"

  versioning {
    enabled = false
  }

  tags = {
    Name        = "ExampleS4Bucket"
    Environment = "Test"
  }
}