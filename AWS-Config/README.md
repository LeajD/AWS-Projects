# AWS Config recommended rules 
aws config rules for networks, s3, rds, ec2, root account, codebuild, ecs, dynamodb, glue, sqs, sns, redsfhit, eks, alb, cloudtrail, vpc flow logs and api

![AWS Config diagram](https://d2908q01vomqb2.cloudfront.net/972a67c48192728a34979d9a35164c1295401b71/2020/09/17/AWS-Config-Workflow3.png)
image URL: https://d2908q01vomqb2.cloudfront.net/972a67c48192728a34979d9a35164c1295401b71/2020/09/17/AWS-Config-Workflow3.png

For CICD-Project:
- **codebuild-project-artifact-encryption**  
- **codebuild-project-environment-privileged-check**  
- **codebuild-project-logging-enabled**  
- **codedeploy-auto-rollback-monitor-enabled**  
- **ecs-awsvpc-networking-enabled**
- **ecs-container-insights-enabled**
- **ecs-containers-nonprivileged**

For serverless project:
- **dynamodb-autoscaling-enabled**  
- **dynamodb-in-backup-plan**  
- **glue-job-logging-enabled**  
- **ec2-instance-no-public-ip**  
- **ec2-ebs-encryption-by-default**  
- **sqs-queue-no-public-access**  
- **sns-topic-no-public-access**  
- **s3-bucket-level-public-acess-prohibited**  
- **s3-bucket-public-write-prohibited**
- **redshift-cluster-public-access-check**
- **rds-instance-public-access-check**

For EKS Project:
- **eks-cluster-supported-version**  
- **eks-cluster-logging-enabled**  
- **eks-cluster-secrets-encrypted**
- **eks-endpoint-no-public-access**  
- **alb-http-to-https-redirection-check**  
- **alb-waf-enabled**  

General:
- **vpc-flow-logs-enabled**  
- **api-gw-associated-with-waf**  
- **api-gw-ssl-enabled**  
- **cloudtrail-enabled**  
- **cloudformation-stack-drift-detection-check**  
- **root-account-mfa-enabled**  
- **ebs-snapshot-public-restorable-check**  
- **iam-root-access-key-check**  
- **acm-certificate-expiration-check**  
- **vpc-default-security-group-closed**  
- **access-keys-rotated** 