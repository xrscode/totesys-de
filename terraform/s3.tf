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
