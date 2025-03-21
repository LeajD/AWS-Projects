import os
import subprocess
import requests
import argparse
from github import Github
from datetime import datetime

# Configuration (you can specify it locally or in jenins 'env' section)
GITHUB_TOKEN=os.environ['GITHUB_TOKEN']
#AWS_ACCESS_KEY_ID=os.environ['aws-access-key-id']
#AWS_SECRET_ACCESS_KEY=os.environ['aws-secret-access-key']

REPO_NAME = "LeajD/AWS-Projects"
BASE_BRANCH = "main"
NEW_BRANCH = f"ci-apply-{datetime.now().strftime('%Y-%m-%d')}"
PR_TITLE = "Automated Terraform PR1 from python"
PR_BODY = "This PR was created automatically using python script for Terraform automation and contains Terraform plan results."
AWS_REGION="us-east-1"


def get_latest_commit(repo, branch_name):
    return repo.get_branch(branch_name).commit.sha

def get_changed_dirs():
    changed_files = subprocess.check_output(["git", "diff", "--name-only", "HEAD~1", "--diff-filter=AM"]).decode().splitlines()
    return list(set("/".join(f.split("/")[:-1]) for f in changed_files if f.endswith(".tf")))

def run_terraform_init(directory):
    return subprocess.run(["terraform", "-chdir=" + directory, "init", "-no-color"], capture_output=True, text=True).stdout

def run_terraform_plan(directory):
    return subprocess.run(["terraform", "-chdir=" + directory, "plan", "-no-color"], capture_output=True, text=True).stdout

def run_terraform_apply(directory):
    return subprocess.run(["terraform", "-chdir=" + directory, "apply", "-auto-approve", "-no-color"], capture_output=True, text=True).stdout

def create_pr(repo, branch_name, base_branch, title, body):
    return repo.create_pull(title=title, body=body, head=branch_name, base=base_branch)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["plan", "apply"], help="Action to perform")
    args = parser.parse_args()
    
    g = Github(GITHUB_TOKEN)
    repo = g.get_repo(REPO_NAME)
    changed_dirs = get_changed_dirs()
    results = ""
    
    for directory in changed_dirs:
        run_terraform_init(directory)
        if args.action == "plan":
            result = run_terraform_plan(directory)
            results += f"### Terraform Plan for {directory}:
```
{result}
```
"
        elif args.action == "apply":
            result = run_terraform_apply(directory)
            results += f"### Terraform Apply for {directory}:
```
{result}
```
"
    
    if args.action == "plan":
        pr = create_pr(repo, NEW_BRANCH, BASE_BRANCH, PR_TITLE, PR_BODY)
        pr.create_issue_comment(results)
        print("Pull request created and plan results commented.")
    elif args.action == "apply":
        print("Terraform apply output:")
        print(results)

if __name__ == "__main__":
    main()
