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

# Install Dependencies online.
# Does not require zip package.
# resource "null_resource" "pip_install" {
#   triggers = {
#     shell_hash = "${sha256(file("${path.module}/../src/requirements.txt"))}" 
#   }
#    provisioner "local-exec" {
#     command = "python3 -m pip install -r requirements.txt -t ${path.module}/../src"
#   }
# }

# Set Default Time
resource "aws_ssm_parameter" "set_start_date_1970" {
    name  = "/time"
    type  = "String"
    value = "1900-02-20 18:14:14.000000"
}

# Set Files for Backup:
resource "aws_ssm_parameter" "backup_files" {
  name  = "/backup/files"
  type  = "String"
  value = "{}"  
}