# Ingestion Lambda

# # Define Lambda function for AWS Lambdas:
resource "aws_lambda_function" "ingestion_lambda" {
  # Name the Function:
  function_name = "ingestion"

  # Assign role/permissions:
  role          = aws_iam_role.iam_for_ingestion.arn

  # Define package type:
  package_type = "Image"

  # Set URI to AWS ECR location:
  image_uri = "211125534329.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions:ingestion"

  # Define timeout time (seconds) for Lambda function to run: 
  timeout = 180

  # Define memory required for Lambda function (megabytes).
  memory_size = 512
}

