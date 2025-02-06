resource "aws_s3_bucket" "codebuild_artifacts" {
  bucket = "my-codebuild-javaartifacts-bucket"  # Replace with your bucket name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.codebuild_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_codepipeline" "java_pipeline" {
  name = "java-build-pipeline"
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
      name             = "DockerBuild"
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

}





resource "aws_codebuild_project" "java_build_project" {
  name          = "java-build-project"
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

data "aws_secretsmanager_secret" "github_secret" {
  name = "github-cicd-project"
}

data "aws_secretsmanager_secret_version" "github_secret_version" {
  secret_id = data.aws_secretsmanager_secret.github_secret.id
}


resource "aws_codepipeline_webhook" "java_webhook" {
  name             = "java-pipeline-webhook"
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