# This will setup the backend.
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

# Set Files for Backup:
resource "aws_ssm_parameter" "backup_files" {
  name  = "/backup"
  type  = "String"
  value = "{}"  
}

# Retrieve account ID from Secret Store:
data "aws_secretsmanager_secret" "account_id"{
  name = "account_id_two"
}

# Retrieve secret Value:
data "aws_secretsmanager_secret_version" "account_id_value"{
  secret_id = data.aws_secretsmanager_secret.account_id.id
}