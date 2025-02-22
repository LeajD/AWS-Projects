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

#run terraform init
def run_terraofmr_init():
    init_output = subprocess.run(["terraform", "-chdir=../terraform/" , "init", "-no-color"], capture_output=True, text=True)
    return init_output.stdout if init_output.returncode == 0 else init_output.stderr

def create_pr(repo, branch_name, base_branch, title, body):
    return repo.create_pull(title=title, body=body, head=branch_name, base=base_branch)

def run_terraform_plan(): #validate stage?
    plan_output = subprocess.run(["terraform", "-chdir=../terraform/" , "plan", "-no-color"], capture_output=True, text=True)
    return plan_output.stdout if plan_output.returncode == 0 else plan_output.stderr

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["plan"], help="Action to perform")
    args = parser.parse_args()

    g = Github(GITHUB_TOKEN)
    repo = g.get_repo(REPO_NAME)

    if args.action == "plan":
        latest_commit = get_latest_commit(repo, BASE_BRANCH)
        init_result = run_terraofmr_init()
        pr = create_pr(repo, NEW_BRANCH, BASE_BRANCH, PR_TITLE, PR_BODY)
        plan_result = run_terraform_plan()
        pr.create_issue_comment(f"### Terraform Plan Results:\n```\n{plan_result}\n```")
        print("Pull request created and plan results commented.")

if __name__ == "__main__":
    main()