
#if you want to manage your RDS via EC2 when RDS is privately deployed
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.web_instance_type
  subnet_id                   = aws_subnet.public1.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_kafka_profile.name

  user_data = <<-EOF
    #!/bin/bash
    # Update the OS
    # install sqlcmd here to manage sqlserver or other tool to manage rds db type
    yum update -y
    yum install mysql -y
    EOF

  tags = {
    Name = var.web_instance_name
  }
}