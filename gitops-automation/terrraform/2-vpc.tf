resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.env}-main"
  }
  depends_on = [ 
    aws_ecr_repository.users,
    aws_ecr_repository.payments
]
}