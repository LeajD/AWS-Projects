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

resource "aws_instance" "web4tf" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_customip.id]
}
