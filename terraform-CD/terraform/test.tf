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


resource "aws_instance" "web3tf" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_customip.id]
}
resource "aws_instance" "web4tf" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_customip.id]
}
