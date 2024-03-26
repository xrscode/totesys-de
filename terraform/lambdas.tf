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

data "archive_file" "ingestion_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambdas/ingestion.py"
  output_path = "${path.module}/../lambdas/ingestion.zip"
}

resource "aws_lambda_function" "ingestion_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.ingestion_zip.output_path
  function_name = "ingestion"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "ingestion.handler"
  layers = [aws_lambda_layer_version.layer_one.arn]

  source_code_hash = data.archive_file.ingestion_zip.output_base64sha256

  runtime = "python3.12"
}

# Permissions:
# Create IAM role.
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_ingestion"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


# Define policy document allowing S3 write access.
data "aws_iam_policy_document" "s3_write_policy" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::ingestion-*/*"]
  }
}

# Define policy to get paramter.
data "aws_iam_policy_document" "get_policy" {
  statement {
    actions   = ["ssm:GetParameter"]
    resources = ["arn:aws:s3:::ingestion-*/*", "arn:aws:iam::211125534329:user/xrs-aws"]
  }
}

# Define Policy to allow access to Secrets Manager
data "aws_iam_policy_document" "access_secrets" {
  statement {
    sid    = "AllowLambdaToAccessSecret"
    effect = "Allow"

    actions   = ["secretsmanager:GetSecretValue"]
    resources = [aws_secretsmanager_secret.access_secrets.arn]
  }
}

# Define name of secret to access:
resource "aws_secretsmanager_secret" "access_secrets" {
  name = "totesysDatabase"
  # Other attributes of the secret
}


# Attach S3 write policy to IAM role.
resource "aws_iam_role_policy_attachment" "s3_write_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  
}

# Attach Get Parameter policy to IAM role.
resource "aws_iam_role_policy_attachment" "aws_get_Parameter" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"  
}

# Attach SecretsManager policy to IAM role.
resource "aws_iam_role_policy_attachment" "lambda_access_secret" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}