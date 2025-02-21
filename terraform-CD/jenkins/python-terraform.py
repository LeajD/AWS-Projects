#!/usr/bin/env python3
import subprocess
import os
import sys
import json
import logging
import requests

## Configure logging to output to both the console and a file.
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler("terraform_plan.log")
    ]
)

def get_changed_files():
    """
    Run 'git diff' to get the list of changed files (comparing origin/master to HEAD).
    Adjust the command if your base branch is different.
    """
    try:
        diff_cmd = ["git", "diff", "origin/master...HEAD", "--name-only"]
        result = subprocess.run(diff_cmd, capture_output=True, text=True, check=True)
        files = result.stdout.splitlines()
        logging.debug(f"Changed files: {files}")
        return files
    except Exception as e:
        logging.error(f"Error getting changed files: {e}")
        sys.exit(1)

def filter_tf_files(files):
    """
    Filter the list for files ending with .tf, .tfvars, or .hcl.
    """
    filtered = [f for f in files if f.endswith(".tf") or f.endswith(".tfvars") or f.endswith(".hcl")]
    logging.debug(f"Filtered Terraform files: {filtered}")
    return filtered

def run_terraform_validate():
    """
    Run 'terraform validate' and return the output (without colors).
    """
    try:
        logging.info("Running 'terraform validate'...")
        result = subprocess.run(["terraform", "validate", "-no-color"], capture_output=True, text=True, check=True)
        logging.info("Terraform validate executed successfully.")
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error("Terraform validate failed.", exc_info=True)
        return e.stdout + "\n" + e.stderr

def run_terraform_plan():
    """
    Run 'terraform plan' and return the output (without colors).
    """
    try:
        logging.info("Running 'terraform plan'...")
        result = subprocess.run(["terraform", "plan", "-no-color"], capture_output=True, text=True, check=True)
        logging.info("Terraform plan executed successfully.")
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error("Terraform plan failed.", exc_info=True)
        return e.stdout + "\n" + e.stderr

def run_terraform_apply():
    """
    Run 'terraform apply' with auto approval and return the output.
    """
    try:
        logging.info("Running 'terraform apply'...")
        result = subprocess.run(["terraform", "apply", "-auto-approve", "-no-color"], capture_output=True, text=True, check=True)
        logging.info("Terraform apply executed successfully.")
        return result.stdout
    except subprocess.CalledProcessError as e:
        logging.error("Terraform apply failed.", exc_info=True)
        return e.stdout + "\n" + e.stderr

def post_pr_comment(comment_body):
    """
    Post the given comment_body as a pull request comment using GitHub API.
    Requires environment variables: GITHUB_REPOSITORY, PR_NUMBER, and GITHUB_TOKEN.
    """
    repo = os.environ.get("GITHUB_REPOSITORY")  # e.g., "owner/repo"
    pr_number = os.environ.get("PR_NUMBER")
    token = os.environ.get("GITHUB_TOKEN")
    if not repo or not pr_number or not token:
        logging.error("Missing one of the required environment variables: GITHUB_REPOSITORY, PR_NUMBER, or GITHUB_TOKEN")
        sys.exit(1)

    url = f"https://api.github.com/repos/{repo}/issues/{pr_number}/comments"
    headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    payload = {"body": comment_body}
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 201:
        logging.info("PR comment posted successfully.")
    else:
        logging.error(f"Failed to post PR comment: {response.status_code} {response.text}")

def main():
    if len(sys.argv) < 2:
        logging.error("Usage: python python-terraform.py <validate|plan|apply>")
        sys.exit(1)
    
    action = sys.argv[1].lower()

    if action == "validate":
        # Run terraform validate and post its output as PR comment.
        output_text = run_terraform_validate()
        # Write output for archiving.
        with open("terraform_validate_output.txt", "w") as file:
            file.write(output_text)
        comment = f"Terraform Validate Result:\n```bash\n{output_text}\n```"
        post_pr_comment(comment)

    elif action == "plan":
        # Get changed files and run terraform plan only if relevant changes exist.
        changed_files = get_changed_files()
        tf_files = filter_tf_files(changed_files)
        if not tf_files:
            logging.info("No Terraform-related file changes detected; skipping terraform plan.")
            sys.exit(0)
        logging.info("Detected Terraform file changes: " + ", ".join(tf_files))
        output_text = run_terraform_plan()
        with open("terraform_plan_output.txt", "w") as file:
            file.write(output_text)
        comment = f"Terraform Plan Result:\n```bash\n{output_text}\n```"
        post_pr_comment(comment)

    elif action == "apply":
        output_text = run_terraform_apply()
        with open("terraform_apply_output.txt", "w") as file:
            file.write(output_text)
        comment = f"Terraform Apply Result:\n```bash\n{output_text}\n```"
        post_pr_comment(comment)

    else:
        logging.error("Invalid action. Use 'validate', 'plan' or 'apply'.")
        sys.exit(1)

if __name__ == "__main__":
    main()