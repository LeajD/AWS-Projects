resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "${var.cluster_name}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


resource "aws_ecr_repository" "docker_repo" {
  name = "${var.cluster_name}"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}



#task Definition:
resource "aws_ecs_task_definition" "my_task" {
  family                   = "${var.task_definition_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]               # Use "FARGATE" if running on Fargate
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "my-docker-repo" #must match "imagedefinitions.json container name inside file"
      #image     = data.aws_ecr_image.latest_image_built.image_uri #for latest version
      image     = "${var.AWS_ACCOUNT_ID}.dkr.ecr.${var.AWS_REGION}.amazonaws.com/${var.image_name}:green" #argumentize
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.ecs_log_group.name}"
          "awslogs-region"        = "${var.AWS_REGION}"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn
}



#Unable to load ECS service info for [cluster: my-ecs-cluster, service: my-ecs-service]. arn:aws:ecs:us-east-1:703671893205:service/my-ecs-service failed with MISSIN
resource "aws_ecs_service" "my_ecs_service" {
  name            = "${var.ecs_service_name}"
  cluster         = aws_ecs_cluster.my_ecs_cluster.name
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"  // Explicitly declare Fargate


  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Define your load balancer if needed (used by CodeDeploy for blue/green deployments)
  load_balancer {
    target_group_arn = aws_lb_target_group.prod_tg.arn
    container_name   = "my-docker-repo" #must match 'name' in imagedefinitions.json, change this       // Change to your container name
    container_port   = 80                     // Change to your container port
  }

  network_configuration {
    subnets          = ["subnet-011f5b56124d08d88","subnet-0893a441ca03c2c8a"]             // List of subnet IDs
    #security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true #false for ECR access, can also use VPC Endpoint for ECR
  }

}
