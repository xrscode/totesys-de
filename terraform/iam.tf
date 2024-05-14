# This Terraform file creates necessary permissions for all lambda functions.

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

# Create policy document:
# data "aws_iam_policy_document" "ingestion_policies" {
#   statement {
#     # S3:PutObject - allows upload of files to S3 bucket.
#     # ssm:GetParameter - get information about single parameter
#     # by specifying the parameter name. 
#     # "secretsmanager:GetSecretValue", "secretsmanager:PutSecretValue" - 
#     # Allows data to be writen and read from AWS secrets manager.
#     actions   = ["s3:PutObject", "ssm:GetParameter", "secretsmanager:GetSecretValue", "secretsmanager:PutSecretValue"]
#     # 
#     resources = [
#     # Specifies the AWS resources to which actions apply:
#     # Defines S3 Ingestion bucket:
#       "arn:aws:s3:::ingestion-*/*",
#     # Defines parameter store:
#       "arn:aws:ssm:::parameter/*"
#     # Defines 
#       # "arn:aws:iam::211125534329:user/xrs-aws"
#     ]
#   }
# }

# Attach S3 write policy to IAM role.
resource "aws_iam_role_policy_attachment" "s3_write_policy_attachment" {
  role       = aws_iam_role.iam_for_ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  
}

# Attach Get Parameter policy to IAM role.
# resource "aws_iam_role_policy_attachment" "aws_get_Parameter" {
#   role       = aws_iam_role.iam_for_ingestion.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"  
# }

# Attach Secrets Access policy to IAM role.
resource "aws_iam_role_policy_attachment" "secret_access_policy" {
  role       = aws_iam_role.iam_for_ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Attach ssm:PutParameter to IAM role.
resource "aws_iam_role_policy_attachment" "parameter_access_policy" {
  role       = aws_iam_role.iam_for_ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}