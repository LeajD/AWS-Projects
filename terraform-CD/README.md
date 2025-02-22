# Terraform CI/CD idea and key concepts:
- Github for infra storage and Jenkins source with python script for automation infra provisioning using Terraform. Github will leverage functionalities of Pull Requests, comments for terraform results and branches merging
- Jenkins using Jenkinsfile to manage python automation, extend CI/CD functionalities (e.g. get only diff for terraform and run different terraform commands)
- Python script for executing specific action against Pull Requests (Terraform validate and plan with action results goes into PR Comment section) and specific action against Merging of Pull Requests (Terraform apply with action results returned into PR Comment section)
- Terraform infrastructure running on AWS and to be maintained/updated over CI/CD
- Branching strategy - in project we use main branch with terraform config files, we commit new branches and create Pull Request to main branch that goes through 1) validate 2) plan 3)apply (when merged) lifecycle. There is no division into multiple branches for different environments that would require additional testing/approvals
- We do not allow "terraform destroy" to be applied (terraform apply will only run on new resources, not deleted)
- If we want to allow "CI/CD" provisioning of Terraform infra using Jenkins we can specify new branching commits naming strategy - e.g. start naming branches "ci-apply-$date" and configure Jenkins to trigger only on those branches 


![Terraform CD](terraformCD.png)


---
...
```


- we only run 'terraform plan' against new resources...

git --git-dir={}/.git describe --abbrev=0 --tags --match ci-apply-*) |\
xargs git diff {} --name-only --diff-filter=d | \
grep -E \"^*.(tf|hcl)\" | \
xargs dirname |
sort -u

"ci-apply-${date}" as branching naming for infra automation




1. deploy infra
2. go to jenkins and init plugins + credential ssh-key do gita + multibranch pipeline
3. add agent runner (możliwe że trzeba zmenić reguły SG + wysyłać curl'e na PrivateIP) + nadać opdowiedni label "terraform-runner" (albo tak nazwać od razu)
4. dodać key i secret na AWS jako credentials (osobne credentials type "secret text" z ID: 'aws-access-key-id' oraz 'aws-secret-access-key') ->  tegop nie trzxerba, dajemy po prostu IAM role odpowednią
5. Dostosować ewentualnie środowisko pythona na EC2 worker node
6. dodajemy nowy resource terraform i pushujemy jako "ci-apply-${date}" commit 
7. dpodajemy ClouDfonrt (bo inaczej w us-east-1 Jenkins na Ec2 fafatlanie działa na WEB UI)
8. 