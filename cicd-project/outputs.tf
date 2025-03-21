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



output "ecs_cluster_id" {
  description = "The ID of the ECS Cluster"
  value       = aws_ecs_cluster.my_ecs_cluster.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS Cluster"
  value       = aws_ecs_cluster.my_ecs_cluster.name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS Cluster"
  value       = aws_ecs_cluster.my_ecs_cluster.arn
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}
