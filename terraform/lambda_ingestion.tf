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

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

data "archive_file" "ingestion_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/ingestion.py"
  output_path = "${path.module}/../lambdas/ingestion.zip"
}

resource "aws_lambda_function" "ingestion_lambda" {
  filename      = data.archive_file.ingestion_zip.output_path
  function_name = "ingestion"
  role          = aws_iam_role.iam_for_ingestion.arn
  handler       = "ingestion.handler"
  layers = [aws_lambda_layer_version.layer_one.arn]

  source_code_hash = data.archive_file.ingestion_zip.output_base64sha256

  runtime = "python3.12"
}

# Permissions:
# Create IAM role.
# resource "aws_iam_role" "iam_for_lambda" {
#   name               = "iam_for_ingestion"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }


# # Define policy document allowing S3 write access.
# data "aws_iam_policy_document" "s3_write_policy" {
#   statement {
#     actions   = ["s3:PutObject"]
#     resources = ["arn:aws:s3:::ingestion-*/*", "arn:aws:iam::211125534329:user/xrs-aws"]
#   }
# }

# # Define policy to get.
# data "aws_iam_policy_document" "get_policy" {
#   statement {
#     actions   = ["ssm:GetParameter"]
#     resources = ["arn:aws:s3:::ingestion-*/*", "arn:aws:iam::211125534329:user/xrs-aws"]
#   }
# }


# # Attach S3 write policy to IAM role.
# resource "aws_iam_role_policy_attachment" "s3_write_policy_attachment" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  
# }

# # Attach Get Parameter policy to IAM role.
# resource "aws_iam_role_policy_attachment" "aws_get_Parameter" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"  
# }

# # Attach Secrets Access policy to IAM role.
# resource "aws_iam_role_policy_attachment" "secret_access_policy" {
#   role       = aws_iam_role.iam_for_lambda.name
#   policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
# }


#
# Define SSM Put Parameter Policy.
# data "aws_iam_policy_document" "lambda_ssm_policy" {
#   statement {
#     effect = "Allow"
#     actions = [
#       "ssm:PutParameter"
#     ]
#     resources = ["arn:aws:s3:::ingestion-*/*", "arn:aws:iam::211125534329:user/xrs-aws"]
#   }
# }

# # Attach SSM Put Parameter Policy to role.
# resource "aws_iam_role_policy_attachment" "lambda_ssm_policy_attachment" {
#   role       = aws_iam_role.iam_for_ingestion.name
#   policy_arn = aws_iam_policy.lambda_ssm_policy.arn
# }