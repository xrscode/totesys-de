# Creates Permissions for 'transform' lambda to work. 

# Transform Lambda Policies:
resource "aws_iam_role" "iam_for_transformation" {
# Creates IAM role named 'iam_for_transformation'
  name               = "iam_for_transformation"
# Defines trust policy for this role:
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach S3 write policy to IAM role.
resource "aws_iam_role_policy_attachment" "s3_write_transforamtion" {
  role       = aws_iam_role.iam_for_transformation.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  
}

# Attach Secrets Access policy to IAM role.
resource "aws_iam_role_policy_attachment" "transformation_secrets_access" {
  role       = aws_iam_role.iam_for_transformation.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Attach ssm:PutParameter to IAM role.
resource "aws_iam_role_policy_attachment" "transformation_parameter_access_policy" {
  role       = aws_iam_role.iam_for_transformation.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}


# Create permission for S3 bucket to invoke Lambda function:
resource "aws_lambda_permission" "allow_s3_invoke" {
    # Unique identifier for permission statement:
    statement_id = "AllowS3Invoke"
    # Specifies action being allowed:
    action = "lambda:InvokeFunction"
    # Resolves to 'transform':
    function_name = aws_lambda_function.transform_lambda.function_name
    # Amazon S3 given permission to invoke lambda function:
    principal = "s3.amazonaws.com"
    # Specifies unique identifier:
    source_arn = aws_s3_bucket.ingestion.arn
}

# Create the S3 notification property for S3 Ingestion bucket:
resource "aws_s3_bucket_notification" "bucket_notification" {
    # Specifies the bucket name:
  bucket = aws_s3_bucket.ingestion.bucket

    # References the lambda to be notified:
  lambda_function {
    # References the transformation lambda:
    lambda_function_arn = aws_lambda_function.transform_lambda.arn
    # Specify which event for notification:
    events              = ["s3:ObjectCreated:Put"]
  }
    # Ensures permissions and transform lambda are setup first!
  depends_on = [
    aws_lambda_permission.allow_s3_invoke, 
    aws_lambda_function.transform_lambda
    ]
}