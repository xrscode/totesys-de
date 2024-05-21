# Define IAM policies for EventBridge
# Create IAM role:
# Creates IAM Role for Lambda.
resource "aws_iam_role" "lambda_ingestion" {
  name = "Ingestion EventBridge"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attaches AWS managed policy for basic Lambda execution:
resource "aws_iam_role_policy_attachment" "lambda_ingestion_policy" {
  role       = aws_iam_role.lambda_ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Define EventBridge Rule - set to every 15 minutes:
resource "aws_cloudwatch_event_rule" "every_15_minutes" {
  name                = "every-15-minutes"
  schedule_expression = "rate(15 minutes)"
}

# Lambda Permission:
# Grants EventBridge permission to invoke Lambda function:
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingestion.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_15_minutes.arn
}

# Links EventBridge rule to Lambda function:
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.every_15_minutes.name
  target_id = "lambda"
  arn       = aws_lambda_function.ingestion.arn
}