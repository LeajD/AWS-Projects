# AWS Projects for my DevOps Portfolio (see diagrams in each project dir for quick overview)

# CI-CD on AWS project
This project implements a comprehensive CI/CD infrastructure on AWS using Infrastructure as Code (Terraform) to orchestrate and manage multiple application pipelines. It supports building, testing, and deploying both Java-based and Docker container–based applications into AWS ECS (using blue/green deployments), as well as provisioning and managing related AWS resources like EKS clusters, ALBs, and IAM roles and policies.

(see [AWS CICD Project](eks-project/)).


# Serverless data analytics project
This project showcases a complete AWS CI/CD solution where an EKS cluster is not only provisioned with Terraform but is also actively monitored for health and performance, ensuring a resilient deployment environment for containerized applications. EKS traffic is exposed via proper Load Balancer on AWS and k8s manifest running inside eks with proper Security Group.

(see [AWS EKS Project](cicd-project/)).


# Serverless data analytics project
This project orchestrates a serverless data processing workflow using AWS Step Functions, Lambda functions, AWS Glue, and other AWS services—all provisioned and managed by Terraform. Project simulates micro-transaction processing. Project implements serverless workflow with multiple lambda functions, glue jobs and different AWS databases for different use-cases.

New Transaction is an entry for StepFunctions workflow of JSON Payload that simulates single micro-transaction.
(see [AWS Serverless-StepFunctions Project](serverless-stepfunctions/)).