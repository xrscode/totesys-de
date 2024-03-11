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
      bucket = "terraform-xrs1" 
      key = "tf-state"
      region = "eu-west-2"
    }
}

# Set Default Time
resource "aws_ssm_parameter" "set_start_date_1970" {
    name  = "/time"
    type  = "String"
    value = "1900-02-20 18:14:14.000000"
}