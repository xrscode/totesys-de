# Define Source of Lambda Layer Code
data "archive_file" "lambda_layer_functions_zip"{
    type = "zip"
    output_path = "${path.module}/lambda_layer.zip"
    source_dir = "${path.module}/../src"
}

# Define the AWS Lambda layer
resource "aws_lambda_layer_version" "layer_one" {
    filename = data.archive_file.lambda_layer_functions_zip.output_path
    layer_name = "first_layer"
    compatible_runtimes = ["python3.12"]
}