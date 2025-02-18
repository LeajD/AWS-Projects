#!/usr/bin/env python

import argparse #provide options/flags to the script
import os #parse environment variables
from datetime import datetime #to use as suffix for branch and pull requests names

import yaml #to parse the yaml file
from github import Auth, Github #to create remote branches, pull requests and merge them - it does it without cloning, so no new changes are made to local git repo! -> you can run this script anywehere without your git repo

def pause(env, service, repo,branch): #this function withh pause all CD in the specified environment
    """pause Continous Delivery CD of the service in the target environment"""
    #create pull requests
    #when it's merged - we detect change and release new version or pausing and resuming CD

    #create file path for the Application resource e.g. apps/envs/dev/users/aplication.yaml
    file_path = f'gitops-merging/apps/envs/{env}/{service}/application.yaml'

    #retrieve content of the Application from the remote "main" branch of the repository
    contents=repo.get_contents(file_path, ref=repo.default_branch)
    
    #parse YAML file and load it into a Python dictionary (to modify certain parts of application)
    app = yaml.safe_load(contents.decoded_content.decode())

    #create an ignore annotattion for ALL (*) tags to PAUSE ALL CD
    key = f'argocd-image-updater.argoproj.io/{service}.ignore-tags'
    app['metadata']['annotations'][key] = '*'

    #create yaml file with application resource (to update argoCD Application resource) that includes an ignore annotation create above
    app_yaml = yaml.dump(app, default_flow_style=False, explicit_start=True)

    #update Application resource from app_yaml file in the remote 'pause-<env>-<date>' branch of the repository
    repo.update_file(contents.path, f'Pause {service} in {env}.' , app_yaml, contents.sha, branch=branch)

    #Log the action that was performed.
    print(f'Updated the "{file_path}" file in the "{branch}" branch of the "{repo.name}" remote repository')

def resume(env, service, repo, branch): #function to un-freeze CD in the specified environment 

    """resume Continous Delivery CD of the service in the target environment"""

    # create a file path for the Application resouce g.g apps/envs/dev/users/application.yaml
    file_path = f'gitops-merging/apps/envs/{env}/{service}/application.yaml'

    #retrieve content of the Application from the remote "main" branch of the repository
    contents = repo.get_contents(file_path, ref=repo.default_branch)

    #parse yaml file and load it into a python dictionary (to modify certain parts of application)
    app = yaml.safe_load(contents.decoded_content.decode())

    #remove and ignore annotation to ignore all tags using ".pop" method
    key = f'argocd-image-updater.argoproj.io/{service}.ignore-tags'
    app['metadata']['annotations'].pop(key, None)

    #create yaml file with application resource that includes an ignore annotation
    app_yaml = yaml.dump(app, default_flow_style=False, explicit_start=True)

    #update Application resource from app_yaml file in the remote 'resume-<env>-<date>' branch of the repository
    repo.update_file(contents.path, f'Resume {service} in {env}.', app_yaml, contents.sha, branch=branch)

    #Log the action that was performed.
    print(f'Updated the "{file_path}" file in the "{branch}" branch of the "{repo.name}" remote repository')

#these functions will go over each applicatins in the nvirtonemnt when you have 2 or 100 argocd applicatins
def get_versions(charts_dir, env, repo): #function that will go over each servicve and collect the latest deployed versions , we run this function to test all specific versions together, you will take these versions after testing and prepare them for the production push
    """get latest deployed versions of all argocd applications in the target environment"""

    #initalize a dictioanry to store latest deployed version
    versions = {}

    # get all helm charts from charts directory (files created by image-updater from newly deployed tags to ECR) - we iterate over all files and get new versions
    services = repo.get_contents(charts_dir)

    #go over each service and get the latest deployed version
    for service in services:
        # create a path for the file e.g. helm-chartrs/payments/.argocd-source-payments.yaml
        file_path=f'{service.path}/.argocd-source-{service.name}-{env}.yaml'

        #retrieve content of the application file from the remote "main" branch of the repository
        contents = repo.get_contents(file_path, ref=repo.default_branch)

        #parse yaml file and load it into python dictionary
        params = yaml.safe_load(contents.decoded_content.decode())

        #go over each Helm parameter and save the image tag of each service into a dictionary
        for param in params['helm']['parameters']:
            if param['name'] == 'image.tag':
                versions[service.name] = param['value']

    #return service versions
    return versions

def options(): #function to parse CLI arguments (e.g. environemnt or action-pause/resume/push)
    """Add command-line arguments to the script"""

    # crewate an instance of the ArgumentParser
    parser = argparse.ArgumentParser()

    #add an source environment flag for the prod push - e.g. dev,staging
    parser.add_argument('--source-env', help='select source environment')
    #add target environment flag for the prod push - e.g. prod
    parser.add_argument('--target-env', help='select target environment')
    #add action flag to pause, resume or push
    parser.add_argument('--action', help='select action to perform')

    return parser.parse_args()

def update_versions(env, versions, repo, branch): #function to perform production push - this function gets newest development version and push  it to pro
    """update service versions to the latest ones deployed in the specified environment"""

    # create a path for the target env folder, e.g. apps/envs/prod
    target_dir = f'gitops-merging/apps/envs/{env}'

    #iterate over all production applicaion and prepare prod push request - collect all subfolders in current environment (payments and users in this case)
    services = repo.get_contents(target_dir)

    #iterate over each production applications and prepare file path for application.yaml, we will use original application.yaml files to update versions
    for service in services:
        file_path = f'{service.path}/application.yaml'

        #read the content of the Application from the remote "main" branch of the repository
        content = repo.get_contents(file_path, ref=repo.default_branch)

        #parse yaml file and load it into a python dictionary
        app = yaml.safe_load(content.decoded_content.decode())

        #initialize a new list to store existing helm parameters
        new_params = []

        #go over eachp parameter that is not an image tagb and add it to the list
        for param in app['spec']['source']['helm']['parameters']:
            if param['name'] != 'image.tag':
                new_params.append(param)

        # create a new imag e tah with the latest version and add it to the list
        image_tag = { 'name': 'image.tag', 'value': versions[service.name] }
        new_params.append(image_tag)

        # set image tag to the latest deployd version
        app['spec']['source']['helm']['parameters'] = new_params        

        #convert python directory into a file
        app_yaml = yaml.dump(app, default_flow_style=False, explicit_start=True)

        #iupdate application resource in the remote 'push-<env>-<date>' branch of the repository for the pull request
        repo.update_file(content.path, f'Update {service.name} to the latest version in {env}.', app_yaml, content.sha, branch=branch)

        # print log action that ws performed   
        print(f'Updated the "{file_path}" file in the "{branch}" branch of the "{repo.name}" remote repository')


def create_branch(repo,branch): #function to create a new branch in the repository
    """create a new branch in the github repository"""
    #take default branch
    sb = repo.get_branch(repo.default_branch)

    #create new branch in remote repo
    repo.create_git_ref(ref=f'refs/heads/{branch}', sha=sb.commit.sha)

    #log the action that was performed
    print(f'Created the "{branch}" branch in the "{repo.name}" remote repository')

def create_pr(repo, branch, title): #you can change config in main branch or use this pull request to create pull request and allow for review
    """ Create a pull request in the github repository"""

    #get reference to main branch
    base = repo.default_branch

    #create pull request
    repo.create_pull(title=title, head=branch, base=base)

    #log the action that was performed 
    print(f'Created the "{branch}" pull request in the "{repo.name}" remote repository')

def get_repo(name): #function to create github repo instance
    """Get GitHub repository by name"""

    #get personal auth token from env varialbe (first you create it and export via "export GITHUB_TOKEN=your_token")
    github_token = os.environ['GITHUB_TOKEN']

    #create authorization based on the token
    auth = Auth.Token(github_token)

    #authorize with Github
    g = Github(auth=auth)

    #return GitHub repository
    return g.get_repo(name)

def main(): #main function to run the script with core logic
    """Entrypoint to GitOps script"""

    #get github repo for k8s deployments:
    repository = get_repo('LeajD/AWS-Projects') #replace this with your repo

    #parse cli arguments:
    args = options()

    #get today's date to use as a suffix for branch and pull request names
    today = datetime.now().strftime('%Y-%m-%d')

    #create a path for target env 
    env_dir = f'gitops-merging/apps/envs/{args.target_env}'

    #freeze selected environment, e.g. stop CD for all services
    if args.action == 'pause':
        #create a new branch name for pull request, e.g. pause-dev-2021-09-01
        new_branch = f'pause-{args.target_env}-{today}'

        #create new branch
        create_branch(repository, new_branch)

        #retrieve applications  (payments and users in this case)
        services = repository.get_contents(env_dir) 

        #go over each application and add an annotattion to disable argocd image updater
        for svc in services:
            pause(args.target_env, svc.name, repository, new_branch)

        #create pull request to disable CD
        create_pr(repository, new_branch, f'Pause CD in {args.target_env}')

    #unfreeze selected environment - to resume CD for all applications
    if args.action == 'resume':
        #create a new branch name for pull request, e.g. resume-dev-2021-09-01
        new_branch = f'resume-{args.target_env}-{today}'

        #create new branch
        create_branch(repository, new_branch)

        #retrieve applications (payments and users in this case)
        services = repository.get_contents(env_dir)

        #go over each application and remove an annotation to enable argocd image updater
        for svc in services:
            resume(args.target_env, svc.name, repository, new_branch)

        #create pull request to enable CD
        create_pr(repository, new_branch, f'Resume CD in {args.target_env}')

    #if action is push - update all applications in the target environment to the latest deployed versions
    if args.action == 'push':
        #create a new branch name for pull request, e.g. push-dev-prod-2021-09-01
        new_branch = f'push-{args.source_env}-{args.target_env}-{today}'

        #create new branch
        create_branch(repository, new_branch)

        #get latest deployed versions of all applications in the source environment
        latest_versions = get_versions('gitops-merging/apps/helm-charts/', args.source_env, repository) 

        #update all applications in the target environment to the latest deployed versions
        update_versions(args.target_env, latest_versions, repository, new_branch)

        #create pull request to update versions
        create_pr(repository, new_branch, f'Production push versions from {args.source_env} to {args.target_env}')

if __name__ == '__main__':
    main()