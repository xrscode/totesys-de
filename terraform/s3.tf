# Create S3 buckets.
resource "aws_s3_bucket" "ingestion" {
    # Creates prefix to ensure uniqueness:
    bucket_prefix = "ingestion-"
    # Allows bucket to be destroyed:
    force_destroy = true
}

# Creates Process Bucket:
resource "aws_s3_bucket" "process" {
    bucket_prefix = "process-"
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

