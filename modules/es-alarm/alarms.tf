data "aws_caller_identity" "default" {}

locals {
  thresholds = {
    FreeStorageSpaceThreshold        = max(var.free_storage_space_threshold, 0)
    MinimumAvailableNodes            = max(var.min_available_nodes, 0)
    CPUUtilizationThreshold          = min(max(var.cpu_utilization_threshold, 0), 100)
    JVMMemoryPressureThreshold       = min(max(var.jvm_memory_pressure_threshold, 0), 100)
    MasterCPUUtilizationThreshold    = min(max(coalesce(var.master_cpu_utilization_threshold, var.cpu_utilization_threshold), 0), 100)
    MasterJVMMemoryPressureThreshold = min(max(coalesce(var.master_jvm_memory_pressure_threshold, var.jvm_memory_pressure_threshold), 0), 100)
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_is_red" {
  
  alarm_name          = "${var.domain_name}-ClusterStatus-IsRed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterStatus.red"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Average elasticsearch cluster status is in red over last 1 minutes"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
  treat_missing_data  = "ignore"
  

  dimensions = {
    DomainName = var.domain_name
    ClientId = data.aws_caller_identity.default.account_id
   

    
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_status_is_yellow" {
  
  alarm_name          = "${var.domain_name}-ClusterStatusIsYellow"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Average elasticsearch cluster status is in yellow over last 1 minutes"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.domain_name
    ClientId = data.aws_caller_identity.default.account_id
  

   
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_too_low" {
  
  alarm_name          = "${var.domain_name}-FreeStorageSpaceTooLow"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Minimum"
  threshold           = local.thresholds["FreeStorageSpaceThreshold"]
  alarm_description   = "Average elasticsearch free storage space over last 1 minutes is too low"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.domain_name
    ClientId = data.aws_caller_identity.default.account_id

    
  }
}

resource "aws_cloudwatch_metric_alarm" "cluster_index_writes_blocked" {
  
  alarm_name          = "${var.domain_name}-ClusterIndexWritesBlocked"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterIndexWritesBlocked"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Elasticsearch index writes being blocker over last 5 minutes"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.domain_name
    ClientId = data.aws_caller_identity.default.account_id

    
  }
}

resource "aws_cloudwatch_metric_alarm" "insufficient_available_nodes" {
  count               = var.monitor_insufficient_available_nodes ? 1 : 0
  alarm_name          = "${var.domain_name}-InsufficientAvailableNodes"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Nodes"
  namespace           = "AWS/ES"
  period              = "86400"
  statistic           = "Minimum"
  threshold           = local.thresholds["MinimumAvailableNodes"]
  alarm_description   = "Elasticsearch nodes minimum < ${local.thresholds["MinimumAvailableNodes"]} for 1 day"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.domain_name
    ClientId = data.aws_caller_identity.default.account_id

    
  }
}

resource "aws_cloudwatch_metric_alarm" "automated_snapshot_failure" {
  
  alarm_name          = "${var.domain_name}-AutomatedSnapshotFailure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "AutomatedSnapshotFailure"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Elasticsearch automated snapshot failed over last 1 minutes"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
  treat_missing_data  = "ignore"

  dimensions = {
    DomainName = var.domain_name
    ClientId = data.aws_caller_identity.default.account_id

    
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  
  alarm_name          = "${var.domain_name}-CPUUtilizationTooHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ES"
  period              = "900"
  statistic           = "Average"
  threshold           = local.thresholds["CPUUtilizationThreshold"]
  alarm_description   = "Average elasticsearch cluster CPU utilization over last 45 minutes too high"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DomainName = var.domain_name
    ClientId = data.aws_caller_identity.default.account_id

    
  }
}

resource "aws_cloudwatch_metric_alarm" "jvm_memory_pressure_too_high" {
  
  alarm_name          = "${var.domain_name}-JVMMemoryPressure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "JVMMemoryPressure"
  namespace           = "AWS/ES"
  period              = "900"
  statistic           = "Maximum"
  threshold           = local.thresholds["JVMMemoryPressureThreshold"]
  alarm_description   = "Elasticsearch JVM memory pressure is too high over last 15 minutes"
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DomainName = var.domain_name
    ClientId = data.aws_caller_identity.default.account_id

   
  }
}