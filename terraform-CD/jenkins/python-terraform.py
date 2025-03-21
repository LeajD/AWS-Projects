import subprocess
import argparse
import re
from github import Github

GITHUB_TOKEN = "your_token_here"
REPO_NAME = "your_repo_here"
BASE_BRANCH = "main"
NEW_BRANCH = "feature-branch"
PR_TITLE = "Terraform Infra Change"
PR_BODY = "Applying infrastructure changes based on latest commit."


def get_latest_commit(repo, branch_name):
    return repo.get_branch(branch_name).commit.sha


def get_changed_files():
    changed_files = subprocess.check_output(["git", "diff", "--name-status", "HEAD~1"]).decode().splitlines()
    modified_files = [line.split("\t")[1] for line in changed_files if line.startswith("M") or line.startswith("A")]
    return [f for f in modified_files if f.endswith(".tf")]


def extract_resources_from_file(file_path):
    resource_pattern = re.compile(r'resource\s+"([^"]+)"\s+"([^"]+)"')
    resources = []
    
    try:
        with open(file_path, "r") as file:
            content = file.read()
            matches = resource_pattern.findall(content)
            resources = [f"{match[0]}.{match[1]}" for match in matches]
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    
    return resources


def run_terraform_init(directory):
    return subprocess.run(["terraform", "-chdir=" + directory, "init", "-no-color"], capture_output=True, text=True).stdout


def run_terraform_plan(directory, resources):
    cmd = ["terraform", "-chdir=" + directory, "plan", "-no-color"]
    for resource in resources:
        cmd.extend(["-target", resource])
    return subprocess.run(cmd, capture_output=True, text=True).stdout


def run_terraform_apply(directory, resources):
    cmd = ["terraform", "-chdir=" + directory, "apply", "-auto-approve", "-no-color"]
    for resource in resources:
        cmd.extend(["-target", resource])
    return subprocess.run(cmd, capture_output=True, text=True).stdout


def create_pr(repo, branch_name, base_branch, title, body):
    return repo.create_pull(title=title, body=body, head=branch_name, base=base_branch)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["plan", "apply"], help="Action to perform")
    args = parser.parse_args()
    
    g = Github(GITHUB_TOKEN)
    repo = g.get_repo(REPO_NAME)
    changed_files = get_changed_files()
    results = ""
    
    for file in changed_files:
        directory = "/".join(file.split("/")[:-1])  # Extract directory from file path
        resources = extract_resources_from_file(file)
        if not resources:
            continue
        
        run_terraform_init(directory)
        
        if args.action == "plan":
            result = run_terraform_plan(directory, resources)
            results += f"### Terraform Plan for {file}:
```
{result}
```
"
        elif args.action == "apply":
            result = run_terraform_apply(directory, resources)
            results += f"### Terraform Apply for {file}:
```
{result}
```
"
    
    if args.action == "plan":
        pr = create_pr(repo, NEW_BRANCH, BASE_BRANCH, PR_TITLE, PR_BODY)
        pr.create_issue_comment(results)
        print("Pull request created and plan results commented.")
    elif args.action == "apply":
        merged_pr = next((pr for pr in repo.get_pulls(state="closed", head=f"{repo.owner.login}:{NEW_BRANCH}") if pr.merged), None)
        if merged_pr:
            merged_pr.create_issue_comment(results)
            print("Terraform apply results commented on merged PR.")
        else:
            print(f"No merged PR found for branch {NEW_BRANCH}")


if __name__ == "__main__":
    main()
