
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
