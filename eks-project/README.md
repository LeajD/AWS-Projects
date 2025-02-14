# AWS EKS Project for private production environment with complex monitoring and Load Balancing

This project exemplifies a comprehensive AWS solution where critical elements—provisioning a managed Kubernetes cluster, configuring a load balancer for external access, and establishing detailed monitoring—come together to deliver a resilient and scalable infrastructure using best practices in Infrastructure as Code.

- **EKS Cluster with monitoring and load balancing diagram:**
![EKS Cluster Project](eksproject.png)


## Key AWS Services and Their Roles:

- **AWS Elastic Kubernetes Service**  
**Managed Node Groups**  
Node groups are configured with parameters for desired, minimum, and maximum sizes as specified in variables.tf, ensuring the cluster can scale as needed.

- **Private subnet deployment**  
*Private Subnets:*
Worker nodes are placed in private subnets with no public IP addresses. Communication between nodes, load balancers, and other AWS services happens over internal VPC networking. Access to cluster API can be granted via STS and "enable_cluster_creator_admin_permissions" setting for EKS defined in terraform configuration.
*NAT Gateway/Instance:*
For outbound internet connectivity (for example, pulling container images or updates), nodes typically route through a NAT gateway/instance in a public subnet.
*VPC Endpoints:*
AWS VPC endpoints can be configured for services like Amazon S3, ECR, and CloudWatch Logs, allowing secure access from private subnets without routing traffic through the public internet.

- **IAM roles for service accounts (IRSA)**

IAM Roles for Service Accounts (IRSA) is an AWS feature that allows you to assign IAM roles directly to Kubernetes service accounts in your EKS cluster. This lets your pods assume specific permissions without requiring node-level credentials. This is done via "annotations" eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/<iam-role-name>



- **Addons & Logging**  
Essential addons like CoreDNS, kube-proxy, and the AWS VPC CNI are enabled. Additionally, logging types (audit, API, authenticator, etc.) are configured to provide better visibility into the cluster operations.

- **Network Load Balancer (NLB)**  
A Kubernetes Service manifest defines an NLB to expose applications running on the cluster. It maps the service port to a target port and references security groups, ensuring secure external access.

- **AWS CloudWatch**  
*Node Health:*
Alarms for node CPU and memory utilization ensure nodes are operating within healthy thresholds.
*Pod Metrics:*
Alarms watch for indicators such as the number of running pods, pending pods, container restarts, and filesystem utilization.
*API Server Performance:*
Metrics like API request duration are tracked to detect latency issues.
*Network & Node Count:*
Monitoring network errors and node count provides insight into the cluster’s overall stability and scalability.

- **Amazon SNS**  
Notifications:
All CloudWatch alarms are configured to trigger actions on an SNS topic. An email subscription (using a notification email defined in variables) ensures that stakeholders are alerted promptly when thresholds are breached.


- **Cost Opimization for EKS Clusters:**  
Saving Plans
Utilize AWS Savings Plans for compute services to reduce the cost of EC2 instances running your worker nodes. Savings Plans offer lower rates in exchange for a commitment, which can be beneficial if you have predictable workloads.

- **Combine multiple teams into single EKS cluster based on namespaces and roles access**  
By hosting several teams on a single cluster and using namespaces along with RBAC (role-based access control), you avoid the overhead of running multiple clusters. This shared environment can reduce management and infrastructure costs while providing resource isolation via Kubernetes namespaces.

- **Spot instances**  
Leverage EC2 Spot Instances for running non-critical or fault-tolerant parts of your workloads. Spot Instances are available at a significant discount compared to on-demand (and especially reserved) pricing but come with the possibility of interruption. Use them for batch jobs, workloads with flexible scheduling, or for scaling down cost-intensive tasks.

- **Graviter instances**  
Consider using AWS Graviton-based instances (e.g., using Arm-based processors) which typically deliver better price performance than traditional x86 instances. They can be particularly effective for workloads optimized for Arm architectures and are great for reducing compute costs.

- **Karpenter**  
Karpenter is an open-source node autoscaler that dynamically provisions and scales worker nodes based on real-time demand. Using Karpenter helps minimize idle resources and reduces cost by efficiently matching supply with demand through automated scaling and optimization of instance types.

- **Kubecost**  
Integrate Kubecost into your cluster to gain real-time cost insights and recommendations. Kubecost helps you track spending at the namespace or even per-deployment level, identify cost anomalies, and provides guidance to reallocate resources and reduce waste.

- **Cost-tags**  
Ensure that all your AWS resources—including EKS, EC2 instances, ECR repositories, and associated networking components—are properly tagged with cost allocation tags. This allows you to monitor and allocate costs accurately across teams, projects, or business units, enabling more informed budgeting and cost-cutting strategies.


// be aware of limit for ingress rules (100 ingress rules per Load Balancer)