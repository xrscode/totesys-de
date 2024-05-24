# Code in here is deprecated and not to be used

# Ingestion Lambda to create zip file and upload to AWS Lambda.
# Create ZIP file
# Reads ingestion.py from lambdas folder.
# data "archive_file" "ingestion_zip" {
#   type        = "zip"
#   source_file = "${path.module}/../lambdas/ingestion.py"
#   output_path = "${path.module}/../lambdas/ingestion.zip"
# }

# # Define Lambda function for AWS Lambdas:
# resource "aws_lambda_function" "ingestion_lambda" {
#   # Link to Lambda function:
#   filename      = data.archive_file.ingestion_zip.output_path
#   # Name of function:
#   function_name = "ingestion"
#   # Assign role/permissions:
#   role          = aws_iam_role.iam_for_ingestion.arn
#   # Define handler function (function used when called by AWS Lambda)
#   handler       = "ingestion.handler"
#   # Define layers - dependencies and functions necessary to run
#   layers = [aws_lambda_layer_version.layer_one.arn]
#   # Define timeout time (seconds) for Lambda function to run: 
#   timeout = 180
#   # Define memory required for Lambda function (megabytes).
#   memory_size = 512

#   source_code_hash = data.archive_file.ingestion_zip.output_base64sha256
#   # Define runtime
#   runtime = "python3.12"
# }

# TRANSFORM LAMBDA:
# Deploy Transformation Lambda

# Zip up transformation Lambda
# data "archive_file" "transform_zip" {
# # Specify type of file:
#   type        = "zip"
# # Specify location of file:
#   source_file = "${path.module}/../lambdas/transform.py"
# # Creates an output path:
#   output_path = "${path.module}/../lambdas/transform.zip"
# }

# # Create the Lambda function in AWS
# resource "aws_lambda_function" "transform_lambda" {
# # Location of file, comes from zip.
#   filename      = data.archive_file.transform_zip.output_path
# # Create name of lambda function in AWS:
#   function_name = "transform"
# # Specify IAM role Lambda function will assume.
# # Defines permissions Lambda function has.
#   role          = aws_iam_role.iam_for_transformation.arn
# # Defines name of handler function.  ingestion.py > def handler()
#   handler       = "transform.handler"
# # Lambda layers function depends on.  layer one:
#   layers = [aws_lambda_layer_version.layer_one.arn]
# # AWS Lambda updates only if code changes.
#   source_code_hash = data.archive_file.transform_zip.output_base64sha256
# # Define timeout time (seconds) for Lambda fucntion to run:
#   timeout = 180
# # Define memory size required for Lambda function (megabytes):
#   memory_size = 512
# # Define runtime:
#   runtime = "python3.12"
# }



# LAYERS:
# Define Source of Lambda Layer Code
# And Create ZIP File.
# data "archive_file" "lambda_layer_functions_zip"{
#     type = "zip"
#     output_path = "${path.module}/lambda_layer.zip"
#     source_dir = "${path.module}/../src"
# }

# # Define the AWS Lambda layer
# resource "aws_lambda_layer_version" "layer_one" {
#     filename = data.archive_file.lambda_layer_functions_zip.output_path
#     layer_name = "first_layer"
#     compatible_runtimes = ["python3.12"]
# }


# # Upload the zip file to S3 bucket for backup
# resource "aws_s3_object" "lambda_layer_zip" {
#   bucket = "terraform-xrs1"
#   key    = "lambda_layer.zip"
#   source = data.archive_file.lambda_layer_functions_zip.output_path
# }