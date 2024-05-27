# Ingestion Lambda
# Retrieve account ID from Secret Store:
data "aws_secretsmanager_secret" "account_id"{
  name = "account_id_two"
}

# Retrieve secret Value:
data "aws_secretsmanager_secret_version" "account_id_value"{
  secret_id = data.aws_secretsmanager_secret.account_id.id
}

# # Define Lambda function for AWS Lambdas:
resource "aws_lambda_function" "ingestion_lambda" {
  
  
  # Name the Function:
  function_name = "ingestion"

  # Assign role/permissions:
  role          = aws_iam_role.iam_for_ingestion.arn

  # Define package type:
  package_type = "Image"

  # Set URI to AWS ECR location:
  image_uri = "${jsondecode(data.aws_secretsmanager_secret_version.account_id_value.secret_string)["my_secret_string"]}.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions:ingestion"

  # Define timeout time (seconds) for Lambda function to run: 
  timeout = 180

  # Define memory required for Lambda function (megabytes).
  memory_size = 512
}