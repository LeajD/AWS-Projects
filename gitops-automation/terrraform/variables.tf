variable ecr_payments {
    description = "ECR repository for payments"
    type        = string
    default     = "payments"
}

variable ecr_users {
    description = "ECR repository for users"
    type        = string
    default     = "users"
}

variable region {
    description = "AWS region"
    type        = string
    default     = "us-east-1"
}

variable "argocd_version" {
    description = "ArgoCD version"
    type        = string
    default     = "7.3.11"
}