data "terraform_remote_state" "ecs" {
  backend = "local"

  config = {
    path = "../ecs/terraform.tfstate"
  }
}

data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "../../networking/terraform.tfstate"
  }
}


resource "aws_ecr_repository" "docker_repo" {
  name = "my-docker-repo"
  
  image_scanning_configuration {
    scan_on_push = true
  }

}


resource "aws_codepipeline" "docker_pipeline" {
  name = "docker-build-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = "my-codebuild-javaartifacts-bucket"
  }
  stage {
    name = "Source"
    action {
      name             = "GitHubSource-custom"
      category         = "Source"
      owner            = "AWS" 
      provider          = "CodeStarSourceConnection" 
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        ConnectionArn = "arn:aws:codeconnections:us-east-1:703671893205:connection/167f271a-6574-4e19-9b52-2e4e3742aac1" #"arn:aws:secretsmanager:us-east-1:703671893205:secret:github-cicd-project-FJI72W"
        FullRepositoryId = "LeajD/Terraform"
        BranchName = "main"
      }
    }
  }


  stage {
    name = "Build"
    action {
      name             = "DockerBuild"
      version          = "1"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.docker_build_project.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "ECSDeploy"
      version          = "1"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      input_artifacts  = ["build_output"]
      configuration = {
        ClusterName = data.terraform_remote_state.ecs.outputs.ecs_cluster_name
        ServiceName = "my-ecs-service"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

resource "aws_codebuild_project" "docker_build_project" {
  name          = "docker-build-project"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 60
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/standard:4.0"
    privileged_mode = true
    environment_variable {
      name  = "DOCKER_REPO_URL"
      value = aws_ecr_repository.docker_repo.repository_url
  }

  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/LeajD/Terraform.git"
    buildspec       = "cicd/java-app/buildspec.yml"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  artifacts {
    type = "S3"
    location = "my-codebuild-javaartifacts-bucket"
  }

}

# IAM Policy for CodeBuild to access Secrets Manager
resource "aws_iam_policy" "codebuild_secrets_manager_policy" {
  name        = "codebuild-policy"
  description = "Policy to allow CodeBuild to access GitHub OAuth token from Secrets Manager"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = "arn:aws:secretsmanager:us-east-1:703671893205:secret:github-cicd-project-FJI72W"
      },
      {
        Effect   = "Allow",
        Action   = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        Resource  = "arn:aws:logs:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:log-group:/aws/codebuild/*"
      },
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
  name               = "codebuild-role"
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
  name   = "CodePipelineS3PutObjectPolicy"
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
  name = "codedeploy-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codedeploy.amazonaws.com"
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



# Added CodeDeploy application resource
resource "aws_codedeploy_app" "docker_codedeploy_app" {
  name              = "docker-codedeploy-app"
  compute_platform  = "ECS"
}

resource "aws_lb" "alb_prod" {
  name               = "alb-prod-ecs"
  internal           = false
  load_balancer_type = "application"
  #security_groups    = [aws_security_group.alb_sg.id]  // Reference your ALB security group
  subnets            = ["subnet-011f5b56124d08d88","subnet-0893a441ca03c2c8a"]              // List of public subnet IDs

  enable_deletion_protection = false

  tags = {
    Environment = "ecs-dev"
  }
}

resource "aws_lb_target_group" "prod_tg" {
  name        = "prod-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"  # Use "ip" for ECS tasks using awsvpc networking
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "prod_listener" {
  load_balancer_arn = aws_lb.alb_prod.arn  // Reference your Application Load Balancer resource
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_tg.arn
  }
}

resource "aws_lb_target_group" "test_tg" {
  name        = "test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
}

resource "aws_lb_listener" "test_listener" {
  load_balancer_arn = aws_lb.alb_prod.arn  // Reference your Application Load Balancer resource
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test_tg.arn
  }
}

#Unable to load ECS service info for [cluster: my-ecs-cluster, service: my-ecs-service]. arn:aws:ecs:us-east-1:703671893205:service/my-ecs-service failed with MISSIN
resource "aws_ecs_service" "my_ecs_service" {
  name            = "my-ecs-service"
  cluster         = data.terraform_remote_state.ecs.outputs.ecs_cluster_name
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Define your load balancer if needed (used by CodeDeploy for blue/green deployments)
  load_balancer {
    target_group_arn = aws_lb_target_group.prod_tg.arn
    container_name   = "my-container"         // Change to your container name
    container_port   = 80                     // Change to your container port
  }

  network_configuration {
    subnets          = ["subnet-011f5b56124d08d88","subnet-0893a441ca03c2c8a"]             // List of subnet IDs
    #security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  launch_type = "EC2" // or "FARGATE" based on your setup
}

#latest docker image: (error if not exist)
#data "aws_ecr_image" "latest_image_built" {
#  repository_name = var.image_name #name of ecr repository (defines specific container image)
#  most_recent     = true
#}


#task Definition:
resource "aws_ecs_task_definition" "my_task" {
  family                   = "my-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]               # Use "FARGATE" if running on Fargate
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "my-container"
      #image     = data.aws_ecr_image.latest_image_built.image_uri
      image     = "${var.AWS_ACCOUNT_ID}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/${var.image_name}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])

  execution_role_arn = data.terraform_remote_state.ecs.outputs.ecs_task_execution_role_arn
  task_role_arn      = data.terraform_remote_state.ecs.outputs.ecs_task_role_arn
}

# Added CodeDeploy deployment group resource
resource "aws_codedeploy_deployment_group" "docker_codedeploy_group" {
  app_name              = aws_codedeploy_app.docker_codedeploy_app.name
  deployment_group_name = "docker_codedeploy_group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = aws_lb_target_group.prod_tg.name
      }
      target_group {
        name = aws_lb_target_group.test_tg.name
      }
      prod_traffic_route {
        listener_arns = [aws_lb_listener.prod_listener.arn]
      }
      test_traffic_route {
        listener_arns = [aws_lb_listener.test_listener.arn]
      }
    }
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                        = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  ecs_service {
    cluster_name = data.terraform_remote_state.ecs.outputs.ecs_cluster_name
    service_name = "my-ecs-service"
  }

  trigger_configuration {
    trigger_events    = ["DeploymentSuccess"]
    trigger_name      = "NotifyDeploymentSuccess"
    trigger_target_arn = aws_sns_topic.eks_alarms.arn
  }
}

resource "aws_sns_topic" "eks_alarms" {
  name = "eks-cloudwatch-alarms"
}




resource "aws_codepipeline_webhook" "docker_webhook" {
  name             = "docker-pipeline-webhook"
  target_pipeline  = aws_codepipeline.docker_pipeline.name
  target_action    = "Build"
  authentication   = "GITHUB_HMAC"

  authentication_configuration {
    secret_token = jsondecode(data.aws_secretsmanager_secret_version.github_secret_version.secret_string)["githubtoken"]

  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/test"
  }
}


resource "aws_iam_policy" "codestar_connections_policy" {
  name        = "codestar-connections-policy"
  description = "Policy to allow UseConnection action on CodeStar connection" #without this policy we get "unable to use connector"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codestar-connections:UseConnection"
        ]
        Resource = "arn:aws:codeconnections:us-east-1:703671893205:connection/167f271a-6574-4e19-9b52-2e4e3742aac1" #specify here
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
