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

    # Args:
    #     function_name (str): The name of the Lambda function.
    #     role (str): The Amazon Resource Name (ARN) of the IAM role that the Lambda function can assume.
    #     handler (str): The name of the function (within your code) that Lambda calls to start execution.
    #     runtime (str): The runtime environment for the Lambda function.
    #     s3_bucket (str): The name of the Amazon S3 bucket that contains the deployment package.
    #     s3_key (str): The Amazon S3 object (the deployment package) key name.
    #     layers (list): List of ARNs of Lambda layers to attach to the Lambda function.
    #     source_code_hash (str): Base64-encoded representation of the SHA256 hash of the deployment package.
    #     memory_size (int): The amount of memory, in MB, that is allocated for the Lambda function.
    #     timeout (int): The function execution time (in seconds) after which Lambda terminates the function.

    # Returns:
    #     None
# }