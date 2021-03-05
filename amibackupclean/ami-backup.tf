resource "aws_lambda_function" "AMI-Backup" {
  function_name = "AMI-Backup"
  handler       = "lambda_function.lambda_handler"
  role          = "arn:aws:iam::845286826995:role/lambda_exec_role"
  runtime       = "python2.7"
  filename      = "backup.zip"
  timeout       = "30"   
  environment {
    variables = {
      AWS_ACCOUNT_NUMBER = data.aws_caller_identity.current.account_id
      RETENTION_DAYS     = "5"
    }
  }
}

resource "aws_cloudwatch_event_rule" "backup-event" {
  depends_on          = [aws_lambda_function.AMI-Backup]
  name                = "AMI-Backup-event"
  description         = "AMI Backup Event"
  schedule_expression = "cron(30 08 ? * * *)"
}

resource "aws_cloudwatch_event_target" "lambda-to-event" {
  rule      = aws_cloudwatch_event_rule.backup-event.name
  target_id = "backup"
  arn       = aws_lambda_function.AMI-Backup.arn
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.AMI-Backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.backup-event.arn
}

