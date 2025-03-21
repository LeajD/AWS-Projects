
terraform {
  backend "s3" {
    bucket         = "my-unique-tfstate-bucket-1234"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
