resource "aws_s3_bucket" "codebuild_artifacts" {
  bucket = "${var.codebuild_artifacts}"  # Replace with your bucket name
  lifecycle {
    prevent_destroy = false #true
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.codebuild_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}



resource "aws_codeartifact_repository" "maven-repo-artifact" {
  domain = var.codeartifact_artifacts_domain
  repository = var.codeartifact_artifacts_repo
}


resource "aws_codepipeline" "java_pipeline" {
  name = var.java_pipeline
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
      owner            = "AWS" #"ThirdParty"
      provider          = "CodeStarSourceConnection" #"GitHub"
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
      name             = "JavaBuild"
      version          = "1"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.java_build_project.name
      }
    }
  }
  # Manual Approval Stage before triggering Project B
  stage {
    name = "Approval"
    action {
      name            = "ManualApproval"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = "1"
      configuration = {
        CustomData = "Please approve to trigger docker building with java plugin"
      }
    }
  }
  stage {
    name = "Build-docker-with-java"
    action {
      name             = "DockerBuildWithJava"
      version          = "1"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["builddockerwithjava_output"]
      configuration = {
        ProjectName = aws_codebuild_project.docker_build_project.name
      }
    }
  }

    stage {
    name = "DeployDockerWithJava"
    action {
      name             = "ECSDeploy-docker-with-java"
      version          = "1"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      input_artifacts  = ["builddockerwithjava_output"]
      role_arn     = aws_iam_role.codedeploy_role.arn #important
      configuration = {
        ClusterName = data.terraform_remote_state.ecs.outputs.ecs_cluster_name
        ServiceName = aws_ecs_service.my_ecs_service.name
        FileName    = "imagedefinitions.json"
        #\codebuild\output\src3028065180\src\cicd-project\cicd\docker-app\
      }
    }
  }



}





resource "aws_codebuild_project" "java_build_project" {
  name          = var.java_build_project
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 60
  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux-x86_64-standard:4.0" # change as needed
    privileged_mode = true
    type            = "LINUX_CONTAINER"   # Changed from the default container environment
    environment_variable {
      name  = "DOCKER_REPO_URL"
      value = aws_ecr_repository.docker_repo.repository_url
  }

  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/LeajD/Terraform.git"
    buildspec       = "cicd-project/cicd/java-app/buildspec.yml"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  artifacts {
    type = "S3"
    location = aws_s3_bucket.codebuild_artifacts.bucket
  }

}

data "aws_secretsmanager_secret" "github_secret" {
  name = var.github_secret
}

data "aws_secretsmanager_secret_version" "github_secret_version" {
  secret_id = data.aws_secretsmanager_secret.github_secret.id
}


resource "aws_codepipeline_webhook" "java_webhook" {
  name             = "${var.java_webhook}"
  target_pipeline  = aws_codepipeline.java_pipeline.name
  target_action    = "Build"
  authentication   = "GITHUB_HMAC"

  authentication_configuration {
    secret_token = jsondecode(data.aws_secretsmanager_secret_version.github_secret_version.secret_string)["githubtoken"]
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/main"
  }
}