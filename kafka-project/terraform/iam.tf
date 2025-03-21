resource "aws_iam_role" "kafka_connect_role" {
  name = var.kafka_connect_role_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "kafkaconnect.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
        }
      }
    }
  ]
}
EOF
}

  
resource "aws_iam_policy" "kafka_connect_policy" {
    name        = var.kafka_connect_policy_name
    description = "Policy for Kafka Connect to access Kafka clusters and S3 resources"
    policy      = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "kafka-cluster:Connect",
          "kafka-cluster:DescribeCluster"
        ],
        "Resource": [
          "${aws_msk_cluster.provisioned_cluster.arn}",
          "${aws_msk_cluster.provisioned_cluster.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "kafka-cluster:ReadData",
          "kafka-cluster:DescribeTopic"
        ],
        "Resource": [
          "${aws_msk_cluster.provisioned_cluster.arn}",
          "${aws_msk_cluster.provisioned_cluster.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "kafka-cluster:WriteData",
          "kafka-cluster:DescribeTopic"
        ],
        "Resource": [
          "${aws_msk_cluster.provisioned_cluster.arn}",
          "${aws_msk_cluster.provisioned_cluster.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "kafka-cluster:CreateTopic",
          "kafka-cluster:WriteData",
          "kafka-cluster:ReadData",
          "kafka-cluster:DescribeTopic"
        ],
        "Resource": [
          "${aws_msk_cluster.provisioned_cluster.arn}",
          "${aws_msk_cluster.provisioned_cluster.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "kafka-cluster:AlterGroup",
          "kafka-cluster:DescribeGroup"
        ],
        "Resource": [
          "${aws_msk_cluster.provisioned_cluster.arn}",
          "${aws_msk_cluster.provisioned_cluster.arn}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:*"
        ],
        "Resource": [
          "${aws_s3_bucket.kafka_bucket.arn}",
          "${aws_s3_bucket.kafka_bucket.arn}/*"
        ]
      }
    ]
  }
  EOF
  }
  
  resource "aws_iam_role_policy_attachment" "kafka_connect_attachment" {
    role       = aws_iam_role.kafka_connect_role.name
    policy_arn = aws_iam_policy.kafka_connect_policy.arn
  }



  # Create an IAM role with an assume-role policy for EC2
resource "aws_iam_role" "ec2_kafka_role" {
  name = var.ec2_kafka_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach the provided Kafka policy as an inline policy for the role
resource "aws_iam_policy" "ec2_kafka_policy" {
  name   = var.ec2_kafka_policy_name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:Connect",
        "kafka-cluster:AlterCluster",
        "kafka-cluster:DescribeCluster"
      ],
      "Resource": [
        "${aws_msk_cluster.provisioned_cluster.arn}",
        "${aws_msk_cluster.provisioned_cluster.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:*Topic*",
        "kafka-cluster:WriteData",
        "kafka-cluster:ReadData"
      ],
      "Resource": [
        "${aws_msk_cluster.provisioned_cluster.arn}",
        "${aws_msk_cluster.provisioned_cluster.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:AlterGroup",
        "kafka-cluster:DescribeGroup"
      ],
      "Resource": [
        "${aws_msk_cluster.provisioned_cluster.arn}",
        "${aws_msk_cluster.provisioned_cluster.arn}/*"
      ]
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ec2_kafka_attachment" {
  role       = aws_iam_role.ec2_kafka_role.name
  policy_arn = aws_iam_policy.ec2_kafka_policy.arn
}

# Create an instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_kafka_profile" {
  name = var.ec2_kafka_profile_name
  role = aws_iam_role.ec2_kafka_role.name
}