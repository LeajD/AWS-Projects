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