resource "aws_s3_bucket" "ingestion" {
    bucket_prefix = "ingestion-"
    force_destroy = true
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