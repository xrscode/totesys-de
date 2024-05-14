# Ingestion Lambda to create zip file and upload to AWS Lambda.

# Create ZIP file
# Reads ingestion.py from lambdas folder.
data "archive_file" "ingestion_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/ingestion.py"
  output_path = "${path.module}/../lambdas/ingestion.zip"
}

# Define Lambda function for AWS Lambdas:
resource "aws_lambda_function" "ingestion_lambda" {
  # Link to Lambda function:
  filename      = data.archive_file.ingestion_zip.output_path
  # Name of function:
  function_name = "ingestion"
  # Assign role/permissions:
  role          = aws_iam_role.iam_for_ingestion.arn
  # Define handler function (function used when called by AWS Lambda)
  handler       = "ingestion.handler"
  # Define layers - dependencies and functions necessary to run
  layers = [aws_lambda_layer_version.layer_one.arn]
  # Define timeout time (seconds) for Lambda function to run: 
  timeout = 180
  # Define memory required for Lambda function (megabytes).
  memory_size = 512

  source_code_hash = data.archive_file.ingestion_zip.output_base64sha256
  # Define runtime
  runtime = "python3.12"
}

