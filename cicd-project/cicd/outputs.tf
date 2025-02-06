output "java_pipeline_name" {
  description = "The name of the Java CodePipeline"
  value       = aws_codepipeline.java_pipeline.name
}

output "java_pipeline_arn" {
  description = "The ARN of the Java CodePipeline"
  value       = aws_codepipeline.java_pipeline.arn
}

output "java_build_project_name" {
  description = "The name of the Java CodeBuild project"
  value       = aws_codebuild_project.java_build_project.name
}

output "java_build_project_arn" {
  description = "The ARN of the Java CodeBuild project"
  value       = aws_codebuild_project.java_build_project.arn
}



output "docker_pipeline_name" {
  description = "The name of the Docker CodePipeline"
  value       = aws_codepipeline.docker_pipeline.name
}

output "docker_pipeline_arn" {
  description = "The ARN of the Docker CodePipeline"
  value       = aws_codepipeline.docker_pipeline.arn
}

output "docker_codedeploy_app_name" {
  description = "The name of the CodeDeploy application for Docker deployments"
  value       = aws_codedeploy_app.docker_codedeploy_app.name
}

output "docker_codedeploy_group_name" {
  description = "The name of the CodeDeploy deployment group for Docker deployments"
  value       = aws_codedeploy_deployment_group.docker_codedeploy_group.deployment_group_name
}


output "secretsmanager_test" {
  value = jsondecode(data.aws_secretsmanager_secret_version.github_secret_version.secret_string)["githubtoken"]
  sensitive = true
}
