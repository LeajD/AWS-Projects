# AWS 

# EKS Cluster Name
variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "my-eks-cluster"
}

variable "AWS_ACCOUNT_ID" {
  description = "The accout id"
  default     = "703671893205"
}

variable "AWS_REGION" {
  description = "The region name"
  default     = "us-east-1"
}

variable "image_name" {
  description = "The name of docker container image to be built"
  default     = "my-custom-container"
}


variable "cluster_version" {
  description = "The name of the EKS cluster"
  default     = "1.31"
}


# EKS Node Group Name
variable "node_group_name" {
  description = "The name of the EKS node group"
  default     = "eks-node-group"
}

# EKS Node Group Scaling Configuration
variable "node_desired_size" {
  description = "Desired size of the node group"
  default     = 2
}

variable "node_max_size" {
  description = "Maximum size of the node group"
  default     = 3
}

variable "node_min_size" {
  description = "Minimum size of the node group"
  default     = 1
}

# EC2 Instance Types for the Node Group
variable "instance_types" {
  description = "List of EC2 instance types for the node group"
  default     = ["t3.medium"]
}

variable "managed_node_groups_name" {
  description = "Name of the managed node group"
  default     = "example"
}
