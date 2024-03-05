provider "aws" {
    region = "eu-west-2"
}

terraform { 
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.39.0"
      }
    }
    backend "s3" {
      bucket = "terraform-xrs" 
      key = "tf-state"
      region = "eu-west-2"
    }
}

# Set Default Time
resource "aws_ssm_parameter" "starting time" {
    name  = "/time"
    type  = "String"
    value = "1900, 2, 20, 18, 14, 14"
}