#if you want to manage your RDS via EC2 when RDS is privately deployed
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] #jenkins doesn't support amazon2 anymore
  }
}
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_customip.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    sudo yum upgrade -y
    sudo yum install java-17-amazon-corretto -y
    sudo yum install jenkins -y
    sudo systemctl enable jenkins
    sudo systemctl start jenkins
    EOF

  tags = {
    Name = var.web_instance_name
  }
  lifecycle {
    ignore_changes = all
  }

}


resource "aws_instance" "jenkins-runner" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.allow_customip.id]
  associate_public_ip_address = true

  # Attach the IAM instance profile
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install java-17-amazon-corretto -y
    sudo yum install git python3 -y
    sudo python3 -m pip install requests PyGithub
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    sudo yum -y install terraform
    EOF

  tags = {
    Name = var.jenkins_instance_name
  }
  lifecycle {
    ignore_changes = all
  }

}