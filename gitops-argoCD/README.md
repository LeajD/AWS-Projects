# GitOps project inside AWS 

Argo CD is a declarative, GitOps continuous delivery (CD) tool designed specifically for Kubernetes, including Amazon EKS clusters. In general, Argo CD continuously monitors a Git repository that contains Kubernetes manifest files. Any change pushed to the repository is automatically detected and deployed to your EKS cluster, ensuring that your cluster’s state matches your declared configuration in Git. Here’s an overview of its key concepts and how it works:


![ArgoCD AWS](argocd.png)


In summary, Argo CD brings consistency, transparency, and automation to the CD process for EKS clusters on AWS by enabling a Git-based workflow for managing and deploying Kubernetes resources.

Access to EKS Cluster:
1. via aws-auth ConfigMap (mapRoles or mapUsers section) -> deprecated, now "EKS access entries" is recommended approach -> you can use eksctl to manage access entries.
2. via "bootstrapClusterCreatorAdminPermissions" flag during setup

Concept of ArgoCD:

# Applications: 
- An Application in Argo CD represents a single deployment unit—essentially, a group of Kubernetes manifest files (could be also Helm charts) that are stored in a Git repository and define the desired state of your application.
- It specifies the source (Git repo URL, path, and branch/tag), the destination (target cluster and namespace), and the sync policies (automated or manual deployment, retry behavior, etc.).
- The Application controller continuously monitors the Git repository and reconciles the live cluster state with the desired state declared in the Application.

# Other Core Components:
- API Server: Exposes Argo CD’s REST API and the web UI, allowing you to interact with and monitor your Applications.
- Repository Server: Manages cloning and rendering Git repositories, which includes processing the necessary tools (like Helm or Kustomize) to generate the Kubernetes manifests.
- Application Controller: Responsible for the continuous reconciliation loop. It watches for changes in your defined Applications and makes sure that the state running in your cluster aligns with what’s defined in Git.
- Dex or Other OIDC Providers: Often used for authentication, these integrate with Argo CD to provide secure access control.




# Description of this project:
1. Create EKS cluster using "eksctl" command and "eksctl.yaml" config file. Config file includes:
- enabling eks add-ons
- OIDC to enable add-ons
- privateCluster
- declared k8s cluster version
- bootstrapClusterCreatorAdminPermissions to manage k8s cluster

2. Create ArgoCD github connection:
3. Create ArgoCD remote-cluster connection:
3. Create ArgoCD Application: