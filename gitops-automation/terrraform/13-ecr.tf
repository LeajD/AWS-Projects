resource "aws_ecr_repository" "payments" {
  name = var.ecr_payments

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository" "users" {
  name = var.ecr_users

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

data "aws_caller_identity" "current" {}

data "template_file" "image_updater" {
  template = "${file("values/image-updater.yaml.tpl")}"

  vars = {
    account_id = data.aws_caller_identity.current.account_id
    region = var.region
  }
}

resource "local_file" "image_updater_yaml" {
  content  = data.template_file.image_updater.rendered
  filename = "values/image-updater.yaml"
}