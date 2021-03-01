


// CPU Utilization
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  #count               = (var.сpu_utilization_too_high_threshold >= 0 && var.enabled) ? 1 : 0
  alarm_name          = "instance ${var.instance_id}-highCPUUtilization"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 600
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_utilization_too_high_threshold
  alarm_description   = "Average CPU utilization over last 10 minutes too high."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    InstanceId = var.instance_id
  }
}

resource "aws_cloudwatch_metric_alarm" "status_check" {
 
  #count      = var.enabled ? 1 : 0

  alarm_name          = "instance-${var.instance_id}-status-check-"
  alarm_description   = "EC2 instance status check or the system status check has failed."
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Sum"
  period              = 600
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok
  dimensions = {
    InstanceId = var.instance_id
  }
}
