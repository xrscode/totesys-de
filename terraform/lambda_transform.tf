# Deploy Transformation Lambda from AWS ECR
# Create the Lambda function in AWS
resource "aws_lambda_function" "transform_lambda" {
# Create name of lambda function in AWS:
  function_name = "transform"

# Assign role/permissions:
  role          = aws_iam_role.iam_for_transformation.arn

# Define package type:
  package_type = "Image"

# Set URI to AWS ECR location:
  image_uri = "${jsondecode(data.aws_secretsmanager_secret_version.account_id_value.secret_string)["my_secret_string"]}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions:transform"

# Define timeout time (seconds) for Lambda fucntion to run:
  timeout = 180

# Define memory size required for Lambda function (megabytes):
  memory_size = 512

  depends_on = [
    data.aws_secretsmanager_secret.account_id,
    data.aws_secretsmanager_secret_version.account_id_value
    ]
}


