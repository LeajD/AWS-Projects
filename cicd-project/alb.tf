
resource "aws_lb" "alb_prod" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  #security_groups    = [aws_security_group.alb_sg.id]  // Reference your ALB security group
  subnets            = ["subnet-011f5b56124d08d88","subnet-0893a441ca03c2c8a"]              // List of public subnet IDs

  enable_deletion_protection = false

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_lb_target_group" "prod_tg" {
  name        = "${var.prod_tg_name}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"  # Use "ip" for ECS tasks using awsvpc networking
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  health_check { #this is check that blue/green deployment perform to validate if shift to green should happen!
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
  name        = "${var.test_tg_name}"
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

