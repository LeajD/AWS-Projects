variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default = "value"
}

variable "notification_email" {
  description = "Email address to receive SNS notifications"
  type        = string
  default     = "testemail@gmail.com"
}

variable "pods_threshold" {
  description = "number of pods above which cw alarm is triggered"
  type        = number
  default     = "100"
}

variable "pods_restart_threshold" {
  description = "number of pods restarted to be alerted"
  type        = number
  default     = "5"
}
variable "apiserver_request_duration" {
  description = "duration of apiserver_requests"
  type        = number
  default     = "80"
}

variable "node_threshold" {
  description = "percentage of CPU and Memory utilization on nodes to be alerted above this"
  type        = number
  default     = "80"
}

variable "evaluation_period" {
  description = "number of evaluations period to be analyzed for cw alarm"
  type        = number
  default     = "2"
}
variable "period" {
  description = "period in which to analyze metrics for alarm"
  type        = number
  default     = "300"
}

variable "node_count" {
  description = "number of nodes to be alerted below this"
  type        = number
  default     = "2"
}


variable "network_errors" {
  description = "number of network errors"
  type        = number
  default     = "50"
}


variable "pending_pods" {
  description = "number of pending pods number to alert"
  type        = number
  default     = "1"
}


variable "node_running_pods_alarm_name" {
  description = "Alarm name for node running pods"
  type        = string
  default     = "EKS-NodeRunningPods-${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
}

variable "node_cpu_utilization_alarm_name" {
  description = "Alarm name for node CPU utilization"
  type        = string
  default     = "EKS-NodeCPUUtilization-${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
}

variable "node_memory_utilization_alarm_name" {
  description = "Alarm name for node memory utilization"
  type        = string
  default     = "EKS-NodeMemoryUtilization-${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
}

variable "apiserver_request_duration_alarm_name" {
  description = "Alarm name for API server request duration"
  type        = string
  default     = "EKS-APIServerLatency-${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
}

variable "node_count_alarm_name" {
  description = "Alarm name for node count"
  type        = string
  default     = "EKS-NodeCount-${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
}

variable "network_errors_alarm_name" {
  description = "Alarm name for network errors"
  type        = string
  default     = "EKS-NetworkErrors-${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
}

variable "node_filesystem_utilization_alarm_name" {
  description = "Alarm name for node filesystem utilization"
  type        = string
  default     = "EKS-NodeFilesystemUtilization-${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
}

variable "pod_restart_count_alarm_name" {
  description = "Alarm name for pod restart count"
  type        = string
  default     = "EKS-PodRestartCount-${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
}

variable "pending_pods_alarm_name" {
  description = "Alarm name for pending pods"
  type        = string
  default     = "EKS-PendingPods-${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
}