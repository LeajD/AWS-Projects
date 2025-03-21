# AWS Projects for my DevOps Portfolio 
```
see visual diagrams in each project dir for quick overview
```
# AWS-Config rules recommended for each project 
This section provides list of recommended AWS Config rules for each project and also general-purpose on network/account level.

(see [AWS Config](AWS-Config/)).

# Load-Balancing 
Simple project to showcases ECS cluster running container tasks exposed via load balancer 443 port using custom CA certificate stored in AWS Private Certificate Authority and custom SSL certificate generated for Load Balancer. Load Balancer of type Application has Web Application Firewall (AWS WAF) and CloudFront distribution enabled custom security group.
(see [Load-Balancing](Load-Balancing/)).

# Transit-Gateway
Explaination of inter-VPC and inter-Account traffic routing inside AWS.
(see [Transit-Gateway](Transit-Gateway/)).

# eksctl with ArgoCD
Project demonstrates how to set up a GitOps workflow for Kubernetes on AWS using Argo CD and `eksctl`. The provided configurations ensure that any changes pushed to the Git repository are automatically applied to the EKS clusters, helping enforce consistency and enabling continuous delivery in your environments.
(see [eksctl with ArgoCD](eksctl-argoCD/)).

# gitops-automation
Project establishes a robust GitOps workflow by combining AWS resource provisioning, declarative application deployments with Argo CD, and a custom Python automation script to streamline CD processes—all managed through Git and pull requests.
(see [gitops-automation](gitops-automation/)).

# kafka-project
This project implements a streaming data pipeline on AWS that integrates several managed services and open-source tools to capture, transform, and move data from a transactional SQL Server database into a data lake stored in S3
(see [kafka-project](kafka-project/)).

# openvpn-module
Deploying an OpenVPN solution on AWS, with emphasis on configuring the security group to restrict access and ensuring proper client setup for VPN connectivity.
(see [openvpn-module](openvpn-module/)).

# Rest of AWS Services
Quick reference guide to various AWS features you can leverage to build scalable, secure, and manageable infrastructures.
(see [Rest of AWS Services](Rest of AWS Services/)).

# Terraform-CD
This project is an end-to-end Terraform CI/CD pipeline that automates infrastructure provisioning on AWS using a combination of Git branching, Jenkins pipelines, and a custom Python automation script. 
(see [Terraform-CD](terraform-CD/)).

# Transit-Gateway
Explains how to set up and use an AWS Transit Gateway to enable network communication between two VPCs—or even between VPCs across different AWS accounts
(see [Transit-Gateway](Transit-Gateway/)).

# CI-CD on AWS project
This project implements a comprehensive CI/CD infrastructure on AWS using Infrastructure as Code (Terraform) to orchestrate and manage multiple application pipelines. It supports building, testing, and deploying both Java-based and Docker container–based applications into AWS ECS (using blue/green deployments), as well as provisioning and managing related AWS resources like EKS clusters, ALBs, and IAM roles and policies.

(see [AWS CICD Project](cicd-project/)).


# EKS project
This project exemplifies a comprehensive AWS solution focused around provisioning a private, production-ready Kubernetes cluster, configuring a load balancer for external access, and establishing detailed monitoring—come together to deliver a resilient and scalable infrastructure using best practices in Infrastructure as Code.

(see [AWS EKS Project](eks-project/)).


# Serverless data analytics project
This project orchestrates a serverless data processing workflow using AWS Step Functions, Lambda functions, AWS Glue, and other AWS services—all provisioned and managed by Terraform. Project simulates micro-transaction processing. Project implements serverless workflow with multiple lambda functions, glue jobs and different AWS databases for different use-cases.

New Transaction is an entry for StepFunctions workflow of JSON Payload that simulates single micro-transaction.
(see [AWS Serverless-StepFunctions Project](serverless-stepfunctions/)).