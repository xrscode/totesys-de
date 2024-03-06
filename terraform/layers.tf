# Define Source of Lambda Layer Code
# data "archive_file" "lambda_layer_functions_zip"{
#     type = "zip"
#     output_path = "${path.module}/lambda_layer.zip"
#     source_dir = "${path.module}/../src"
# }

# # Define the AWS Lambda layer
# resource "aws_lambda_layer_version" "layer_one" {
#     filename = data.archive_file.lambda_layer_functions_zip.output_path
#     layer_name = "first_layer"
#     compatible_runtimes = ["python3.12"]
# }
data "archive_file" "lambda_layer_functions_zip" {
    type        = "zip"
    output_path = "/tmp/lambda_layer.zip"  # Temporarily save zip file locally
    source_dir  = "${path.module}/../src"
}

# Upload the zip file to S3 bucket
resource "aws_s3_bucket_object" "lambda_layer_zip" {
  bucket = "terraform-xrs"
  key    = "lambda_layer.zip"
  source = data.archive_file.lambda_layer_functions_zip.output_path
}

# Define the AWS Lambda layer
resource "aws_lambda_layer_version" "layer_one" {
    filename            = "s3://${aws_s3_bucket_object.lambda_layer_zip.bucket}/${aws_s3_bucket_object.lambda_layer_zip.key}"
    layer_name          = "first_layer"
    compatible_runtimes = ["python3.12"]
}
