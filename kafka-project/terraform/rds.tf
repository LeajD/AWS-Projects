
resource "aws_db_instance" "mssql" {
  allocated_storage             = var.rds_allocated_storage
  storage_encrypted             = var.rds_storage_encrypted
  engine                        = var.rds_engine
  engine_version                = var.rds_engine_version
  instance_class                = var.rds_instance_class
  username                      = var.rds_username
  manage_master_user_password   = true
  license_model                 = var.rds_license_model
  publicly_accessible           = var.rds_publicly_accessible
  skip_final_snapshot           = true
  vpc_security_group_ids        = [aws_security_group.db_sg.id]
  db_subnet_group_name          = aws_db_subnet_group.rds_subnets.name #deploy in specific VPC
   

  tags = {
    Name = var.rds_instance_name
  }
}


#get managed_secret from secrets manager for RDS
data "aws_secretsmanager_secret_version" "rds_secret" {
  secret_id = "${aws_db_instance.mssql.master_user_secret[0].secret_arn}"
}

data "aws_secretsmanager_secret" "rds_secret" {
    arn = "${aws_db_instance.mssql.master_user_secret[0].secret_arn}"
}


# Use a null resource with a local-exec provisioner to create a sample table. - if your RDS is publicly accessible
#resource "null_resource" "create_sample_table" {
#  depends_on = [aws_db_instance.mssql]
#  provisioner "local-exec" {
#    command = <<EOF
#sqlcmd -S ${aws_db_instance.mssql.address},${aws_db_instance.mssql.port} -U ${aws_db_instance.mssql.username} -P "${aws_db_instance.mssql.password}" -d ${aws_db_instance.mssql.name} -Q "CREATE TABLE SampleTable (ID INT PRIMARY KEY, Name NVARCHAR(50));"
#EOF
#  }
#}

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