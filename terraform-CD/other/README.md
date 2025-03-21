# Terraform CD project

We cloud automate this whole terraform infra in such approach:

1. we allow developers only to access "ecs.json" file and they can modify simple parameter
2. this commit triggers jenkins -> python (../python.py) script executes terraform plan that uses ecs.tf file with "data external" resource (generate-ecs.py creates terraform resource we need based on 'ecs.json' definition and 'query' parameters from 'ecs.tf' file) and references this config dynamically provided using "resource" "aws_ecs_task_definition" and "container_definition" section -> then runs 'terraform plan' on it
3. from there we can approve PR and merge and run terraform apply

// this works because ecs.tf will 