# This Terraform file creates necessary permissions.

# Create Assume Role Policy Document
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Ingestion Lambda Policies:
resource "aws_iam_role" "iam_for_ingestion" {
# Creates IAM role named 'iam_for_ingestion'
  name               = "iam_for_ingestion"
# Defines trust policy for this role:
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


# Define policy document allowing S3 write access.
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

data "aws_iam_policy_document" "ingestion_policies" {
  statement {
    actions   = ["s3:PutObject", "ssm:GetParameter", "secretsmanager:GetSecretValue", "secretsmanager:PutSecretValue"]
    resources = [
      "arn:aws:s3:::ingestion-*/*",
      "arn:aws:ssm:::parameter/*",
      "arn:aws:iam::211125534329:user/xrs-aws"
    ]
  }
}

# Attach S3 write policy to IAM role.
resource "aws_iam_role_policy_attachment" "s3_write_policy_attachment" {
  role       = aws_iam_role.iam_for_ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  
}

# Attach Get Parameter policy to IAM role.
resource "aws_iam_role_policy_attachment" "aws_get_Parameter" {
  role       = aws_iam_role.iam_for_ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"  
}

# Attach Secrets Access policy to IAM role.
resource "aws_iam_role_policy_attachment" "secret_access_policy" {
  role       = aws_iam_role.iam_for_ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}