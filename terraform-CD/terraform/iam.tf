# Create an IAM role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "terraform_iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Create a policy that grant only  access to AWS infra for Terraform deployments !!!
resource "aws_iam_policy" "terraform_policy" {
  name        = "terraform_full_access_policy"
  description = "Policy granting full access to AWS for Terraform deployments."
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "FullAccess",
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_terraform_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.terraform_policy.arn
}

# Create an instance profile from the IAM role
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "terraform_instance_profile"
  role = aws_iam_role.ec2_role.name
}