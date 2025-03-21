# AWS 

# EKS Cluster Name
variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "my-eks-cluster"
}

variable "AWS_ACCOUNT_ID" {
  description = "The accout id"
  default     = ""
}

variable "AWS_REGION" {
  description = "The region name"
  default     = "us-east-1"
}

variable "image_name" {
  description = "The name of docker container image to be built"
  default     = "my-docker-repo"
}


variable "cluster_version" {
  description = "The name of the EKS cluster"
  default     = "1.31"
}


# EKS Node Group Name
variable "node_group_name" {
  description = "The name of the EKS node group"
  default     = "eks-node-group"
}

# EKS Node Group Scaling Configuration
variable "node_desired_size" {
  description = "Desired size of the node group"
  default     = 2
}

variable "node_max_size" {
  description = "Maximum size of the node group"
  default     = 3
}

variable "node_min_size" {
  description = "Minimum size of the node group"
  default     = 1
}

# EC2 Instance Types for the Node Group
variable "instance_types" {
  description = "List of EC2 instance types for the node group"
  default     = ["t3.medium"]
}

variable "managed_node_groups_name" {
  description = "Name of the managed node group"
  default     = "example"
}



# AWS 

# EKS Cluster Name
variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "my-eks-cluster"
}


variable "cluster_version" {
  description = "The name of the EKS cluster"
  default     = "1.31"
}


# EKS Node Group Name
variable "node_group_name" {
  description = "The name of the EKS node group"
  default     = "eks-node-group"
}

# EKS Node Group Scaling Configuration
variable "node_desired_size" {
  description = "Desired size of the node group"
  default     = 2
}

variable "node_max_size" {
  description = "Maximum size of the node group"
  default     = 3
}

variable "node_min_size" {
  description = "Minimum size of the node group"
  default     = 1
}

# EC2 Instance Types for the Node Group
variable "instance_types" {
  description = "List of EC2 instance types for the node group"
  default     = ["t3.medium"]
}

variable "managed_node_groups_name" {
  description = "Name of the managed node group"
  default     = "example"
}



variable "alb_name" {
  type        = string
  description = "Name for the Application Load Balancer"
  default     = "alb-prod-ecs"
}

variable "environment" {
  type        = string
  description = "Environment tag for the ALB resources"
  default     = "ecs-dev"
}


variable "prod_tg_name" {
  type        = string
  description = "Name for the production target group"
  default     = "prod-tg"
}
variable "test_tg_name" {
  type        = string
  description = "Name for the test target group"
  default     = "test-tg"
}
variable "task_definition_name" {
  type        = string
  description = "Task definition  name"
  default     = "my-ecs-task-bluegreen"
}
variable "ecs_service_name" {
  type        = string
  description = "ecs service  name"
  default     = "my-ecs-service-bluegreen"
}
variable "ecs_task_execution_role" {
  type        = string
  description = "ecs_task_execution_role name"
  default     = "ecs-task-execution-role"
}
variable "ecs_task_role" {
  type        = string
  description = "ecs_task_role name"
  default     = "ecs-task-role"
}


variable "codebuild_secrets_manager_policy" {
  type        = string
  description = "codebuild_secrets_manager_policy name"
  default     = "codebuild-policy"
}
variable "codebuild_role" {
  type        = string
  description = "codebuild_role name"
  default     = "codebuild-role"
}


variable "codepipeline_s3_policy" {
  type        = string
  description = "CodePipelineS3PutObjectPolicy name"
  default     = "CodePipelineS3PutObjectPolicy"
}

variable "maven-repo-artifact" {
  type        = string
  description = "maven-repo-artifact name"
  default     = "maven-repo-artifact"
}

variable "codestar_connection_id" {
  type        = string
  description = "codestar_connection_id name"
  default     = "SPECIFY" #SPECIFY CODESTAR CONNECTION FOR GITHUB
}
variable "codedeploy_role" {
  type        = string
  description = "codedeploy_role name"
  default     = "codedeploy-service-role"
}
variable "codestar_connections_policy" {
  type        = string
  description = "codestar_connections_policy name"
  default     = "codestar-connections-policy"
}
variable "my_codeartifact_policy" {
  type        = string
  description = "my_codeartifact_policy name"
  default     = "test-java-maven-artifact"
}
variable "ecs_task_execution_policy" {
  type        = string
  description = "ecs_task_execution_policy name"
  default     = "ecs-task-execution-policy"
}
variable "ecs_task_execution_attach" {
  type        = string
  description = "ecs_task_execution_attach name"
  default     = "ecs-task-execution-role"
}
variable "java_webhook" {
  type        = string
  description = "java_webhook name"
  default     = "java-pipeline-webhook"
}
variable "codebuild_artifacts" {
  type        = string
  description = "codebuild_artifacts name"
  default     = "my-codebuild-javaartifacts-bucket"
}


variable "codeartifact_artifacts_domain" {
  type        = string
  description = "codeartifact_artifacts_domain name"
  default     = "test-java-maven-artifact"
}

variable "codeartifact_artifacts_repo" {
  type        = string
  description = "codeartifact_artifacts_repo name"
  default     = "docker-java-artifacts"
}
variable "docker_webhook" {
  type        = string
  description = "docker_webhook name"
  default     = "docker-pipeline-webhook"
}
variable "docker_codedeploy_deploymentgroup_name" {
  type        = string
  description = "docker_codedeploy_deploymentgroup_name name"
  default     = "docker_codedeploy_group"
}

variable "docker_codedeploy_app" {
  type        = string
  description = "docker_codedeploy_app name"
  default     = "docker-codedeploy-app"
}

variable "java_pipeline" {
  type        = string
  description = "java_pipeline name"
  default     = "java-build-pipeline"
}

variable "java_build_project" {
  type        = string
  description = "java_build_project name"
  default     = "java-build-project"
}

variable "github_secret" {
  type        = string
  description = "github_secret name"
  default     = "github-cicd-project"
}

variable "docker_pipeline" {
  type        = string
  description = "docker_pipeline name"
  default     = "docker-build-pipeline"
}
variable "docker_build_project" {
  type        = string
  description = "docker_build_project name"
  default     = "docker-build-project"
}
variable "eks_alarms" {
  type        = string
  description = "eks_alarms name"
  default     = "eks-cloudwatch-alarms"
}
