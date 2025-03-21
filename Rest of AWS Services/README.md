# Amnazon Managed Streaming for Apache Kafka

# AWS SDK Boto3:


# AWS Nested Stacks:
Allows you to break a large CloudFormation template into smaller, reusable templates (child stacks) and then reference them from a main (parent) template.
Enhances modularization, reusability, and easier management of complex infrastructure.
# AWS SAM (Serverless Application Model):
A framework that extends CloudFormation to simplify defining and deploying serverless applications.
Uses a simplified syntax to define functions, APIs, databases, and event source mappings, making it quicker to build and test serverless apps locally.

# Elastic Beanstalk:
A Platform-as-a-Service (PaaS) that handles deployment, capacity provisioning, load balancing, scaling, and monitoring of web applications.
Developers simply upload their code, and Beanstalk automatically manages the underlying infrastructure.

# S3 Static Hosting:
Configuring an S3 bucket to serve static content (HTML, CSS, JavaScript) as a static website.
You set up the bucket for website hosting, optionally configure error and index documents, and then access your site via the bucket’s endpoint.

# AWS Service Catalog:
A service that lets organizations create and manage approved catalogs of IT services (CloudFormation templates, etc.) that are preconfigured for specific needs.
It helps enforce governance, standardization, and best practices across service deployments.

# VPC Endpoints:
Allow private connectivity between your VPC and supported AWS services without using an Internet Gateway, NAT device, VPN, or firewall proxy.
Two types exist:
- Gateway Endpoints: Used for services like Amazon S3 and DynamoDB (configures routes in your route tables).
- Interface Endpoints: Use AWS PrivateLink, create an elastic network interface (ENI) in your VPC, and are used for many other AWS services.
