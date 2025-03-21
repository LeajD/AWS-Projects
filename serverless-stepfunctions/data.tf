


data "aws_secretsmanager_secret_version" "rds_secret" {
  secret_id = "${aws_rds_cluster.aurora_cluster.master_user_secret[0].secret_arn}"
}

data "aws_secretsmanager_secret" "rds_secret" {
    arn = "${aws_rds_cluster.aurora_cluster.master_user_secret[0].secret_arn}"
}

data "aws_secretsmanager_secret_version" "redshift_secret" {
  secret_id = "${aws_redshift_cluster.redshift_cluster.master_password_secret_arn}"
}

data "aws_secretsmanager_secret" "redshift_secret" {
    arn = "${aws_redshift_cluster.redshift_cluster.master_password_secret_arn}"
}



resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = var.aurora_cluster_name
  engine                  = "aurora-mysql"
  engine_version          = var.aurora_version  # Adjust to your required Aurora MySQL version
  database_name           = var.aurora_cluster_name
  master_username         = "admin"
  manage_master_user_password = true
  #db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  #vpc_security_group_ids  = var.rds_security_group_ids
  skip_final_snapshot     = true
  storage_encrypted       = true

  tags = {
    Name = "Aurora MySQL Cluster"
  }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  count              = 2
  identifier         = "aurora-instance-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora_cluster.engine
  publicly_accessible = false

  tags = {
    Name = "Aurora MySQL Instance ${count.index + 1}"
  }
}

#interesting way to implement structure for RDS, mysql locally required
#resource "null_resource" "db_schema" {
#  depends_on = [aws_db_instance.rds_instance]
#  provisioner "local-exec" {
#    command = "mysql -h ${aws_db_instance.example.endpoint} -u ${aws_db_instance.example.username} -p${aws_db_instance.example.password} ${aws_db_instance.example.db_name} < ./create_tables.sql"
#  }
#}


# Redshift cluster
resource "aws_redshift_cluster" "redshift_cluster" {
  cluster_identifier     = var.redshift_cluster
  node_type              = var.redshift_size
  master_username        = var.rds_username
  #master_password        = data.aws_secretsmanager_secret.redshift_secret.id       # use secrets for production
  manage_master_password = true
  cluster_type           = "single-node"
  database_name          = var.redshift_db
  skip_final_snapshot    = true
  publicly_accessible     = false
}

# AWS Glue Catalog Database
resource "aws_glue_catalog_database" "glue_database" {
  name = var.glue_database
}

#connection to redshift for aws_glue job to use
resource "aws_glue_connection" "glue_connection" {
  name        = var.glue_connection
  description = "Glue connection to Redshift cluster"
  
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${aws_redshift_cluster.redshift_cluster.endpoint}/${var.redshift_db}"
    SECRET_ID           = data.aws_secretsmanager_secret.redshift_secret.name
  }

}


resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_glue  # Ensure the bucket name is globally unique
  #acl    = "private" #deprecated
}

resource "aws_s3_bucket_ownership_controls" "s3_control" {
  bucket = aws_s3_bucket.my_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "apply_private" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_control]

  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}




resource "aws_cloudwatch_log_group" "my_log_group" {
  name              = var.glue_log_group  # Log group name
  retention_in_days = 7  # Set retention policy (optional, default is never expire)

  tags = {
    Environment = var.environment
  }
}




resource "local_file" "aws-glue" {
  content  = templatefile("${var.aws_glue_name}-template.py", { #file to be changed
    redshifttable = "${aws_redshift_cluster.redshift_cluster.database_name}"
    glueredshiftconnection  = "${aws_glue_connection.glue_connection.name}"
    catalogdatabase = "${aws_glue_catalog_database.glue_database.name}"
    catalogtable = "${var.catalog_table}"
    bucket = "${aws_s3_bucket.my_bucket.bucket}"
  })
  filename = "${var.aws_glue_name}.py" #file that will be created
}
#depend on above resource
resource "aws_s3_object" "glue_redshift" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "${var.aws_glue_name}.py"  # The file name in S3
  source = "./${var.aws_glue_name}.py"  # Path to the local file
  acl    = "private"  # Set appropriate permissions

  depends_on = [ local_file.aws-glue ]
}


resource "aws_glue_job" "glue_job_redshfit" {
  name     = var.glue_job_redshift_name
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.my_bucket.bucket}/${aws_s3_object.glue_redshift.key}"
    python_version  = "3"
  }

  default_arguments = {
    # ... potentially other arguments ...
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.my_log_group.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = "true" #needs IAM role to PutMetrics
    #"--extra-jars"                       = "s3://${aws_s3_bucket.my_bucket.bucket}/jars/redshift-jdbc42-2.1.0.32.jar,s3://${aws_s3_bucket.my_bucket.bucket}/jars/spark-redshift_2.12-6.3.0-spark_3.5.jar"
  }

  max_retries = 0
  timeout     = 10   // Timeout in minutes
}

resource "aws_glue_catalog_database" "glue_db" {
  name = var.glue_catalog_db
}

resource "aws_glue_catalog_table" "table" {
  name          = var.catalog_table
  database_name = aws_glue_catalog_database.glue_db.name
}

# Create a Glue Crawler
resource "aws_glue_crawler" "json_crawler" {
  name          = var.glue_crawler
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.glue_db.name
  table_prefix = var.catalog_table

  s3_target {
    path = "s3://${aws_s3_bucket.my_bucket.bucket}/data/"
  }


}


# IAM Role for Glue Crawler
resource "aws_iam_role" "glue_crawler_role" {
  name = var.AWSGlueServiceRole

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# Attach IAM policy for Glue to access S3
resource "aws_iam_policy" "glue_s3_access_policy" {
  name        = var.GlueS3AccessPolicy
  description = "Allows Glue to access S3 data"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource ="${aws_s3_bucket.my_bucket.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["glue:*"]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "glue_s3_attachment" {
  policy_arn = aws_iam_policy.glue_s3_access_policy.arn
  role       = aws_iam_role.glue_crawler_role.name
}

