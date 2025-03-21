data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../eks/terraform.tfstate"
  }
}


resource "aws_sns_topic" "eks_alarms" {
  name = "eks-cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.eks_alarms.arn
  protocol  = "email"
  endpoint  = var.notification_email  # Your email address for alerts
}


resource "aws_cloudwatch_metric_alarm" "node_number_of_running_pods" {
  alarm_name          = var.node_running_pods_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "node_number_of_running_pods"
  namespace           = "ContainerInsights"
  period              = var.period
  statistic           = "Average"
  threshold           = var.pods_threshold
  alarm_description   = "Triggers if a node has more than 100 running pods"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = data.terraform_remote_state.eks.outputs.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "node_cpu_utilization" {
  alarm_name          = var.node_cpu_utilization_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = var.period
  statistic           = "Average"
  threshold           = var.node_threshold
  alarm_description   = "Triggers if a node's CPU utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = data.terraform_remote_state.eks.outputs.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "node_memory_utilization" {
  alarm_name          = var.node_memory_utilization_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "node_memory_utilization"
  namespace           = "ContainerInsights"
  period              = var.period
  statistic           = "Average"
  threshold           = var.node_threshold
  alarm_description   = "Triggers if a node's memory utilization exceeds 80%"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = data.terraform_remote_state.eks.outputs.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "apiserver_request_duration_seconds" {
  alarm_name          = var.apiserver_request_duration_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "apiserver_request_duration_seconds"
  namespace           = "ContainerInsights"
  period              = var.period
  statistic           = "Average"
  threshold           = var.apiserver_request_duration
  alarm_description   = "Triggers if the API server request duration exceeds 1.5 seconds"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = data.terraform_remote_state.eks.outputs.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "node_count" {
  alarm_name          = var.node_count_alarm_name
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "cluster_node_count"
  namespace           = "ContainerInsights"
  period              = var.period
  statistic           = "Average"
  threshold           = var.node_count
  alarm_description   = "Triggers if the number of nodes drops below 2"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = data.terraform_remote_state.eks.outputs.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "network_errors" {
  alarm_name          = var.network_errors_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "NetworkErrors" #missing metric
  namespace           = "ContainerInsights"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.network_errors
  alarm_description   = "Triggers if network errors exceed 50 in 5 minutes"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = data.terraform_remote_state.eks.outputs.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "node_filesystem_utilization" {
  alarm_name          = var.node_filesystem_utilization_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "node_filesystem_utilization"
  namespace           = "ContainerInsights"
  period              = var.period
  statistic           = "Average"
  threshold           = var.node_threshold
  alarm_description   = "Triggers if filesystem utilization exceeds 85%"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = data.terraform_remote_state.eks.outputs.eks_cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "pod_restart_count" {
  alarm_name          = var.pod_restart_count_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "pod_number_of_container_restarts"
  namespace           = "ContainerInsights"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.pods_restart_threshold
  alarm_description   = "Triggers if a pod's container restarts more than 5 times in 5 minutes"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = data.terraform_remote_state.eks.outputs.eks_cluster_name
  }
}


resource "aws_cloudwatch_metric_alarm" "pending_pods" {
  alarm_name          = var.pending_pods_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.evaluation_period
  metric_name         = "PendingPods"
  namespace           = "AWS/EKS"
  period              = var.period
  statistic           = "Average"
  threshold           = var.pending_pods
  alarm_description   = "Pending pods above 0"
  alarm_actions       = [aws_sns_topic.eks_alarms.arn]

  dimensions = {
    ClusterName = data.terraform_remote_state.eks.outputs.eks_cluster_name
  }
}
