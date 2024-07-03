#!/bin/bash
# This script will setup the infrastructure locally

# Run setup ECR.
python ./.github/workflows/setup.py

# Create Docker Image and Push to ECR
# Build Ingestion Image
cd src
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 211125534329.dkr.ecr.eu-west-2.amazonaws.com
docker build -t 211125534329.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions:ingestion -f Docker_ingestion .
# Build Transformation Image
docker build -t 211125534329.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions:transform -f Docker_transform .

# Push Images to ECR
docker push 211125534329.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions:ingestion
docker push 211125534329.dkr.ecr.eu-west-2.amazonaws.com/lambda_functions:transform 

# # Run Terraform:
cd ..
cd terraform && terraform init && terraform plan && terraform apply -auto-approve


