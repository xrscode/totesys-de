import os
import boto3

# Access the AWS_ECR environment variable:
repo = os.getenv("AWS_ECR")


def remove_ecr(repo_id):
    """
    ARGS:
    Repo ID.  The AWS account ID associated with registry.

    RETURNS:
    Removes repository; 'lambda_functions'
    """

    # Establish ECR Client:
    client = boto3.client('ecr')

    # Remove Repository:
    try:
        response = client.delete_repository(
            registryId=repo_id,
            repositoryName='lambda_functions',
            force=True
        )
    except Exception as e:
        return e


remove_ecr(repo)
