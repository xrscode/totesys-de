#!/bin/bash
# This script will setup the infrastructure locally

# Run remove.py
# Removes the ECR registry.
python ./.github/workflows/remove.py


# # Run Terraform Destroy:
cd terraform && terraform init && terraform plan && terraform destroy -auto-approve