output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks_al2.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster"
  value       = module.eks_al2.cluster_endpoint
}

output "eks_cluster_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value       = module.eks_al2.cluster_oidc_issuer_url
}

output "eks_managed_node_group_iam_role" {
  description = "IAM role attached to the managed node group"
  value       = module.eks_al2.eks_managed_node_groups[var.managed_node_groups_name].iam_role_name
}

output "loadbalancer_variables_file" {
  description = "Path of the generated load balancer variables file"
  value       = local_file.k8s_service.filename
}