

data "terraform_remote_state" "networking" {
  backend = "local"

  config = {
    path = "../../networking/terraform.tfstate"
  }
}




resource "aws_codepipeline" "docker_pipeline" {
  name = var.docker_pipeline
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codebuild_artifacts.bucket
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
      provider         = "CodeDeployToECS" #"ECS" #CodeDeployToECS -> use this in order to trigger CodeDeploy and blue/green via CodePipeline
      input_artifacts  = ["build_output"]
      role_arn     = aws_iam_role.codedeploy_role.arn #important for CodeDeploy to even Execute
      configuration = {  
        ApplicationName      = aws_codedeploy_app.docker_codedeploy_app.name  #config for "CodeDeployToECS"
        DeploymentGroupName  = aws_codedeploy_deployment_group.docker_codedeploy_group.deployment_group_name #config for "CodeDeployToECS"
        #ClusterName = data.terraform_remote_state.ecs.outputs.ecs_cluster_name
        #ServiceName = aws_ecs_service.my_ecs_service.name
        #FileName    = "imagedefinitions.json"
        AppSpecTemplateArtifact       = "build_output",
        TaskDefinitionTemplatePath    = "taskdefinition.json",
        TaskDefinitionTemplateArtifact  = "build_output",
        AppSpecTemplatePath           = "appspec.yml"
      }
    }
  }
}

resource "aws_codebuild_project" "docker_build_project" {
  name          = var.docker_build_project
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 60
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    type            = "LINUX_CONTAINER"
    image           = "aws/codebuild/standard:4.0"
    privileged_mode = true #to enable CodeBuild docker layers caching
    environment_variable {
      name  = "DOCKER_REPO_URL"
      value = aws_ecr_repository.docker_repo.repository_url
  }

  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/LeajD/Terraform.git"
    buildspec       = "cicd-project/cicd/docker-app/buildspec.yml"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  artifacts {
    type = "S3"
    location = "my-codebuild-javaartifacts-bucket"
  }
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

}


# Added CodeDeploy application resource
resource "aws_codedeploy_app" "docker_codedeploy_app" {
  name              = var.docker_codedeploy_app
  compute_platform  = "ECS"
}

#latest docker image: (error if not exist)
#data "aws_ecr_image" "latest_image_built" {
#  repository_name = var.image_name #name of ecr repository (defines specific container image)
#  most_recent     = true
#}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/my-ecs-task"
  retention_in_days = 14
}





# Added CodeDeploy deployment group resource
resource "aws_codedeploy_deployment_group" "docker_codedeploy_group" {
  app_name              = aws_codedeploy_app.docker_codedeploy_app.name
  deployment_group_name = var.docker_codedeploy_deploymentgroup_name
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce" #specify shifting traffic strategy

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
      termination_wait_time_in_minutes = 60
    }
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.my_ecs_cluster.name
    service_name = aws_ecs_service.my_ecs_service.name
  }

  trigger_configuration {
    trigger_events    = ["DeploymentSuccess"]
    trigger_name      = "NotifyDeploymentSuccess"
    trigger_target_arn = aws_sns_topic.eks_alarms.arn
  }
}

resource "aws_sns_topic" "eks_alarms" {
  name = var.eks_alarms
}




resource "aws_codepipeline_webhook" "docker_webhook" {
  name             = var.docker_webhook
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


