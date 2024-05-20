# Create S3 buckets.
resource "aws_s3_bucket" "ingestion" {
    bucket_prefix = "ingestion-"
    force_destroy = true
}

# Create permission for S3 bucket to invoke Lambda function:
resource "aws_lambda_permission" "allow_s3_invoke" {
    statement_id = "AllowS3Invoke"
    action = "lambda:InvokeFunction"
    # Resolves to 'transform':
    function_name = aws_lambda_function.transform_lambda.function_name
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.ingestion.arn
}

# Create the S3 notification property for S3 Ingestion bucket:
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.ingestion.bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.transform_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke, 
    aws_lambda_function.transform_lambda
    ]
}

# Creates Process Bucket:
resource "aws_s3_bucket" "process" {
    bucket_prefix = "process-"
    force_destroy = true
}

# Creates Storage Bucket:
resource "aws_s3_bucket" "storage" {
    bucket_prefix = "storage-"
    force_destroy = true
}

# Stores the names of the Buckets:
resource "aws_ssm_parameter" "ingestion_bucket_name" {
    name  = "/ingestion"
    type  = "String"
    value = aws_s3_bucket.ingestion.bucket
}

resource "aws_ssm_parameter" "process_bucket_name" {
    name  = "/process"
    type  = "String"
    value = aws_s3_bucket.process.bucket
}

resource "aws_ssm_parameter" "storage_bucket_name" {
    name  = "/storage"
    type  = "String"
    value = aws_s3_bucket.storage.bucket
}