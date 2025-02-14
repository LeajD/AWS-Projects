data "aws_caller_identity" "current" {}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.ecs_task_execution_role}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.ecs_task_role}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}


# IAM Policy for CodeBuild to access Secrets Manager
resource "aws_iam_policy" "codebuild_secrets_manager_policy" {
  name        = "${var.codebuild_secrets_manager_policy}"
  description = "Policy to allow CodeBuild to access GitHub OAuth token from Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:github-cicd-project-FJI72W"
      },
      {
        Effect   = "Allow",
        Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        Resource  = "arn:aws:logs:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/*"
      },
      {
        Effect   = "Allow",
        Action   = [
            "s3:GetObject",
            "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.codebuild_artifacts.bucket}/*" // Allows PutObject on all objects in the bucket
      },
      {
        Effect   = "Allow",
        Action   = [
          "codestar-connections:UseConnection"
        ]
        Resource = "arn:aws:codeconnections:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:connection/${var.codestar_connection_id}"
      },

      {
        Effect = "Allow",
        Action = [
          "codeartifact:DescribePackageVersion",
          "codeartifact:DescribeRepository",
          "codeartifact:GetPackageVersionReadme",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ListPackageVersionAssets",
          "codeartifact:ListPackageVersionDependencies",
          "codeartifact:ListPackageVersions",
          "codeartifact:ListPackages",
          "codeartifact:PublishPackageVersion",
          "codeartifact:PutPackageMetadata",
          "codeartifact:ReadFromRepository",
          "codeartifact:ListRepositories",
          "codeartifact:GetAuthorizationToken"
        ]
        Resource = [
          "arn:aws:codeartifact:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:domain/${var.my_codeartifact_policy}",
          "arn:aws:codeartifact:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:repository/${var.maven-repo-artifact}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
            "sts:GetServiceBearerToken"
        ],
        Resource = "*",
        Condition = {
              StringEquals = {
                "sts:AWSServiceName": "codeartifact.amazonaws.com"
              }
          }
        },
      {
        Effect   = "Allow",
        Action   = "ecr:GetAuthorizationToken",
        Resource = "*"
      },
      {
      Effect  = "Allow",
      Action  = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
      ]
      Resource = "${aws_ecr_repository.docker_repo.arn}"
}


    ]
  })
}

# Attach the IAM policy to CodeBuild role
resource "aws_iam_role_policy_attachment" "codebuild_role_policy_attachment" {
  policy_arn = aws_iam_policy.codebuild_secrets_manager_policy.arn
  role       = aws_iam_role.codebuild_role.name
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}



resource "aws_iam_role" "codepipeline_role" {
  name               = "test-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}



resource "aws_iam_role" "codebuild_role" {
  name               = "${var.codebuild_role}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}




resource "aws_iam_policy" "codepipeline_s3_policy" {
  name   = "${var.codepipeline_s3_policy}"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
            "s3:GetObject",
            "s3:PutObject"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.codebuild_artifacts.bucket}/*" // Allows PutObject on all objects in the bucket
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_policy_attach" {
  role       = aws_iam_role.codepipeline_role.name   // Replace with the role used by your pipeline (test-role)
  policy_arn = aws_iam_policy.codepipeline_s3_policy.arn
}

resource "aws_iam_role" "codedeploy_role" {
  name = "${var.codedeploy_role}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service =    "codedeploy.amazonaws.com",
        AWS     = "${aws_iam_role.codepipeline_role.arn}" #important to allow codedeploy role be asssumed by codepipeline role in 'deploy' stage 
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach the necessary policies for CodeDeploy (adjust as needed)
resource "aws_iam_role_policy_attachment" "codedeploy_policy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
resource "aws_iam_policy" "codedeploy_ecs_policy" {
  name   = "CodeDeployECSAccessPolicy"
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeTasks",
          "ecs:ListTaskSets",
          "ecs:DescribeTaskSets",
          "ecs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_ecs_policy_attach-main" {
  role       = aws_iam_role.codedeploy_role.name  // Replace with your CodeDeploy service role resource name
  policy_arn = aws_iam_policy.codedeploy_ecs_policy.arn #aws_iam_policy.codedeploy_ecs_policy.arn
}


resource "aws_iam_policy" "codestar_connections_policy" {
  name        = "${var.codestar_connections_policy}"
  description = "Policy to allow UseConnection action on CodeStar connection" #without this policy we get "unable to use connector"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codestar-connections:UseConnection"
        ]
        Resource = "arn:aws:codeconnections:${var.AWS_REGION}:${data.aws_caller_identity.current.account_id}:connection/${var.codestar_connection_id}"
      },
      {
        Effect   = "Allow",
        Action   = [
          "codebuild:*"
        ],
        Resource = "${aws_codebuild_project.docker_build_project.arn}"
      },
      {
        Effect  = "Allow",
        Action  = [
          "codebuild:*"
        ],
        Resource= "${aws_codebuild_project.java_build_project.arn}"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "test_role_policy_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codestar_connections_policy.arn
}


# IAM Policy for CodePipeline to access Secrets Manager
resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy" {
  role       = aws_iam_role.codepipeline_role.name  # Name of your IAM role
  policy_arn = aws_iam_policy.codebuild_secrets_manager_policy.arn
}


resource "aws_codeartifact_repository_permissions_policy" "my_codeartifact_policy" {
  domain          = "${var.my_codeartifact_policy}"           # Replace with your CodeArtifact domain name
  repository      = "maven-repo-artifact"     # The CodeArtifact repository name

  policy_document = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = "${aws_iam_role.codebuild_role.arn}"
        },
        Action = [
          "codeartifact:DescribePackageVersion",
          "codeartifact:DescribeRepository",
          "codeartifact:GetPackageVersionReadme",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:ListPackageVersionAssets",
          "codeartifact:ListPackageVersionDependencies",
          "codeartifact:ListPackageVersions",
          "codeartifact:ListPackages",
          "codeartifact:PublishPackageVersion",
          "codeartifact:PutPackageMetadata",
          "codeartifact:ReadFromRepository"
        ],
        Resource = "*"
      }

    ]
  })
}


resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "${var.ecs_task_execution_policy}"
  description = "Allows ECS tasks to pull images from ECR and write logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  role       = "${var.ecs_task_execution_attach}"
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}
