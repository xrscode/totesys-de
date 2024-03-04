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

resource "aws_ssm_parameter" "default_start" {
    name = "/time"
    type = "String"
    value = "1970-01-01 00:00:00.000000"
}
