resource "aws_lambda_function" "AMI-Cleanup" {
  function_name = "AMI-Cleanup"
  handler       = "lambda_function.lambda_handler"
  role          = "arn:aws:iam::845286826995:role/lambda_exec_role"
  runtime       = "python2.7"
  filename      = "cleanup.zip"
  timeout       = "120"
  memory_size   = "158"
  environment {
    variables = {
      AWS_ACCOUNT_NUMBER = data.aws_caller_identity.current.account_id
    }
  }
}

resource "aws_cloudwatch_event_rule" "cleanup-event" {
  depends_on          = [aws_lambda_function.AMI-Cleanup]
  name                = "AMI-Cleanup-event"
  description         = "AMI Cleanup Event"
  schedule_expression = "cron(30 09 ? * * *)"
}

resource "aws_cloudwatch_event_target" "lambda-to-event2" {
  rule      = aws_cloudwatch_event_rule.cleanup-event.name
  target_id = "cleanup"
  arn       = aws_lambda_function.AMI-Cleanup.arn
}

resource "aws_lambda_permission" "lambda2" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.AMI-Cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cleanup-event.arn
}

