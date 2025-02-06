resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }


}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
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
  name               = "ecs-task-role"
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

#resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachement" {
#  policy_arn = #here_iamPolicy to allow task_excecution_ACTIONS
#  role       = aws_iam_role.ecs_task_execution_role.name
#}


/*
resource "aws_ecs_task_definition" "docker_task" {
  family                = "my-docker-task"
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  
  container_definitions = jsonencode([{
    name      = "my-container"
    image     = "${aws_ecr_repository.docker_repo.repository_url}:latest"
    cpu       = 256
    memory    = 512
    essential = true
  }])
}
*/