data "external" "service_version_from_application_deployment" {
  program = ["python", "generate-ecs.py"]

  query = { #additional option to pass parameters into terraform resource definition that will be generated
    account      = var.account
    region       = var.aws_region
    cluster      = var.cluster_name
    service_name = var.service_name
  }
}



resource "aws_ecs_task_definition" "my_task" {
  family                   = "custom-dev-task"
  container_definitions    = data.external.ecs_task.result["container_definitions"]

  depends_on = [ data.external.service_version_from_application_deployment ]
}
