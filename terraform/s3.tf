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

# Output Bucket Names:
output "ingestion_bucket_name" {
  value = aws_s3_bucket.ingestion.bucket
}

output "process_bucket_name" {
  value = aws_s3_bucket.process.bucket
}

output "storage_bucket_name" {
  value = aws_s3_bucket.storage.bucket
}