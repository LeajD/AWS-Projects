

resource "aws_security_group" "msk_sg" {
  name        = var.msk_security_group_name
  description = "Security group for MSK cluster"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # Change as appropriate for your environment
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_msk_cluster" "provisioned_cluster" {
  cluster_name           = var.msk_cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.msk_number_of_broker_nodes

  
  broker_node_group_info {
    instance_type   = var.msk_instance_type

    storage_info {
      ebs_storage_info {
        volume_size = var.msk_volume_size
      }
    }

    # Use the provided private subnets for broker nodes
    client_subnets  = [ aws_subnet.private.id, aws_subnet.private2.id ]

    # Attach your MSK security group
    security_groups = [aws_security_group.msk_sg.id]
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  client_authentication {
    sasl {
      iam = true 
    }
  }

  tags = {
    Environment = var.msk_environment_tag
    Name        = var.msk_cluster_tag_name
  }
}


resource "aws_mskconnect_custom_plugin" "connector-sqlserver" {
  name         = var.connector_sqlserver_name
  content_type = "ZIP"
  location {
    s3 {
      bucket_arn = aws_s3_bucket.kafka_bucket.arn
      file_key   = var.connector_sqlserver_file_key
    }
  }
}


resource "aws_mskconnect_custom_plugin" "kafka-connect-s3" {
  name         = var.kafka_connect_s3_plugin_name
  content_type = "ZIP"
  location {
    s3 {
      bucket_arn = aws_s3_bucket.kafka_bucket.arn
      file_key   = var.kafka_connect_s3_plugin_file_key
    }
  }
}
