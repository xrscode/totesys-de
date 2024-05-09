# Deploy Transformation Lambda

# Zip up transformation Lambda
data "archive_file" "transform_zip" {
# Specify type of file:
  type        = "zip"
# Specify location of file:
  source_file = "${path.module}/../lambdas/lambda_transform.py"
# Creates an output path:
  output_path = "${path.module}/../lambdas/transform.zip"
}

# Create the Lambda function in AWS
resource "aws_lambda_function" "transform_lambda" {
# Location of file, comes from zip.
  filename      = data.archive_file.transform_zip.output_path
# Create name of lambda function in AWS:
  function_name = "transform"
# Specify IAM role Lambda function will assume.
# Defines permissions Lambda function has.
# CHANGE CHANGE CHANGE CHANGE *$*%@£%£*$%@£$*@£$%*@£$%*@£$%*£@
  role          = aws_iam_role.iam_for_ingestion.arn
# Defines name of handler function.  ingestion.py > def handler()
  handler       = "ingestion.handler"
# Lambda layers function depends on.  layer one:
  layers = [aws_lambda_layer_version.layer_one.arn]
# AWS Lambda updates only if code changes.
  source_code_hash = data.archive_file.transform_zip.output_base64sha256
  runtime = "python3.12"
}

# Permissions
