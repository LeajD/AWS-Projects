import sys
import json
from jinja2 import Template

def generate_ecs_tf(manifest_path, output_path):
    # Read manifest.json
    with open(manifest_path, 'r') as mf:
        manifest = json.load(mf)
    
    # Example Terraform template for ECS task definition and service
    ecs_template = """
resource "aws_ecs_task_definition" "task" {
  family                   = "{{ service_name }}"
  cpu                      = "{{ cpu }}"
  memory                   = "{{ memory }}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = jsonencode([
    {
      name      = "{{ service_name }}"
      image     = "{{ image }}"
      cpu       = {{ cpu }}
      memory    = {{ memory }}
      essential = true,
      portMappings = [
        {
          containerPort = var.container_port,
          hostPort      = var.container_port
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "{{ service_name }}"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = {{ desired_count }}
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
    assign_public_ip = var.assign_public_ip
  }
}
    """

    template = Template(ecs_template)
    rendered = template.render(**manifest)

    with open(output_path, 'w') as outf:
        outf.write(rendered)

    print("Terraform ECS configuration generated at:", output_path)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python generate_ecs_tf.py <manifest.json> <output.tf>")
        sys.exit(1)

    manifest_file = sys.argv[1]
    output_file = sys.argv[2]
    generate_ecs_tf(manifest_file, output_file)