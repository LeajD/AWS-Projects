
/*
output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
aws eks --region $(terraform output -raw us-east-1) update-kubeconfig \
    --name $(terraform output -raw cluster_name)




output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks_al2.name
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = aws_eks_cluster.eks_cluster.cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.eks_cluster.name
}
*/



output "eks_cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks_al2.cluster_name
}

output "eks_node_role_name" {
  description = "IAM Role Name for EKS Node Group"
  value       = module.eks_al2.eks_managed_node_groups["${var.managed_node_groups_name}"].iam_role_name
}



###
output "node_iam_role_arn" {
  description = "IAM Role ARN for EKS Node Group"
  value       = module.eks_al2.node_iam_role_arn
}

output "node_iam_role_name" {
  description = "IAM Role Name for EKS Node Group"
  value       = module.eks_al2.node_iam_role_name
}
