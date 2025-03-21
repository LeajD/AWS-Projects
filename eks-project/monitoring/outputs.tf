output "sns_topic_arn" {
  description = "The ARN of the SNS topic for EKS alarms"
  value       = aws_sns_topic.eks_alarms.arn
}

output "node_number_of_running_pods_alarm_name" {
  description = "CloudWatch alarm name for node number of running pods"
  value       = aws_cloudwatch_metric_alarm.node_number_of_running_pods.alarm_name
}

output "node_cpu_utilization_alarm_name" {
  description = "CloudWatch alarm name for node CPU utilization"
  value       = aws_cloudwatch_metric_alarm.node_cpu_utilization.alarm_name
}

output "node_memory_utilization_alarm_name" {
  description = "CloudWatch alarm name for node memory utilization"
  value       = aws_cloudwatch_metric_alarm.node_memory_utilization.alarm_name
}

output "apiserver_request_duration_alarm_name" {
  description = "CloudWatch alarm name for API server request duration"
  value       = aws_cloudwatch_metric_alarm.apiserver_request_duration_seconds.alarm_name
}

output "node_count_alarm_name" {
  description = "CloudWatch alarm name for node count"
  value       = aws_cloudwatch_metric_alarm.node_count.alarm_name
}

output "network_errors_alarm_name" {
  description = "CloudWatch alarm name for network errors"
  value       = aws_cloudwatch_metric_alarm.network_errors.alarm_name
}

output "node_filesystem_utilization_alarm_name" {
  description = "CloudWatch alarm name for node filesystem utilization"
  value       = aws_cloudwatch_metric_alarm.node_filesystem_utilization.alarm_name
}

output "pod_restart_count_alarm_name" {
  description = "CloudWatch alarm name for pod restart count"
  value       = aws_cloudwatch_metric_alarm.pod_restart_count.alarm_name
}

output "pending_pods_alarm_name" {
  description = "CloudWatch alarm name for pending pods"
  value       = aws_cloudwatch_metric_alarm.pending_pods.alarm_name
}