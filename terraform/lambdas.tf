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

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_ingestion"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
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
  handler       = "index.test"
  layers = [aws_lambda_layer_version.layer_one.arn]

  source_code_hash = data.archive_file.ingestion_zip.output_base64sha256

  runtime = "python3.12"

#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
}