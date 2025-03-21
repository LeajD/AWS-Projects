# Terraform CI/CD idea and key concepts:

The CI/CD process relies on a branching strategy where Terraform AWS Infrastructure changes are made on dedicated branches (e.g. `ci-apply-<date>`). Those commits trigger Jenkins pipeline that runs Python automation script which creates a pull request, runs `terraform plan`, and posts the plan output as a PR comment. Once the pull request is manually merged into the `main` branch, Jenkins again triggers a Python script which runs Terraform apply to provision the resources and returns result into PR comment section.


- Github for infra storage and Jenkins source with python script for automation infra provisioning using Terraform. Github will leverage functionalities of Pull Requests, comments for terraform results and branches merging
- Jenkins using Jenkinsfile to manage python automation, extend CI/CD functionalities (e.g. get only diff for terraform and run different terraform commands)
- Python script for executing specific action against Pull Requests (Terraform validate and plan with action results goes into PR Comment section) and specific action against Merging of Pull Requests (Terraform apply with action results returned into PR Comment section)
- Terraform infrastructure running on AWS and to be maintained/updated over CI/CD
- Branching strategy - in project we use main branch with terraform config files, we commit new branches and create Pull Request to main branch that goes through 1) plan 2)apply (when merged) lifecycle. There is no division into multiple branches for different environments that would require additional testing/approvals but this can be implemented.
- If we want to allow "CI/CD" provisioning of Terraform infra using Jenkins we can specify new branching commits naming strategy - e.g. start naming branches "ci-apply-$date" and configure Jenkins to trigger only on those branches 


![Terraform CD](terraformCD.png)



To be implemented:
- We want Terraform to be targeted onto files that were changed -> we can use "git diff --diff-filter=AM" to achieve this + we want only to analyze Terraform files -> for that we use "f.endswith(".tf")"
- We do not want to allow "terraform destroy" to be applied (terraform apply will only run on new resources, not deleted)
- We only want to allow new resource to be created, but:
    - "-chdir" argument for Terraform will also check all other resources (even if only one file was modified) + also allows deletion of AWS resources ... but it's still good approach to use "-chdir" if we have multiple directories for terraform resources
    - "-target" argument for Terraform will create single resources but it will also create/destroy other resources from files (doesn't provide functionality we want)
