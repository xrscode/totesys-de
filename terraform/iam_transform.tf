# Creates Permissions for Transform Lambda to work. 

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

# Transform Lambda Policies:
resource "aws_iam_role" "iam_for_transformation" {
# Creates IAM role named 'iam_for_transformation'
  name               = "iam_for_transformation"
# Defines trust policy for this role:
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Attach S3 write policy to IAM role.
resource "aws_iam_role_policy_attachment" "s3_write_policy_attachment" {
  role       = aws_iam_role.iam_for_transformation.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  
}

# Attach Secrets Access policy to IAM role.
resource "aws_iam_role_policy_attachment" "secret_access_policy" {
  role       = aws_iam_role.iam_for_transformation.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Attach ssm:PutParameter to IAM role.
resource "aws_iam_role_policy_attachment" "parameter_access_policy" {
  role       = aws_iam_role.iam_for_transformation.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}