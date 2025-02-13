
Source and Build Stages:
For the Java app, CodeBuild retrieves the source, uses Maven (as defined by POM and settings.xml) to build the application, and packages the artifacts.
For the Docker app, CodeBuild builds the Docker image using the provided Dockerfile and buildspec, and task definition details are outlined in taskdefinition.json.

Artifacts and Pipeline Stages:
Built artifacts are stored in S3 as defined in the artifact stores.
Pipelines include stages for manual approvals, additional builds (if needed), and then automated deployment stages.

Deployment:
Java applications: Are deployed to ECS through CodeDeploy with blue/green deployments to minimize downtime.
Docker containers: Are similarly deployed onto ECS via CodeDeploy using the defined deployment groups, ensuring that production traffic is shifted gradually between blue and green environments.

Infrastructure Management:
The full set of AWS resources — including ECS clusters, IAM roles/policies, ALBs, target groups, and security configurations — are managed by Terraform, ensuring the entire infrastructure remains versioned and repeatable.
