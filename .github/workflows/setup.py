import os
import boto3

# Access the AWS_ECR environment variable:
repo = os.getenv("AWS_ECR")


def check_ecr(repo_name=repo):
    """
    ARGS:
    Repo ID.  The AWS account ID associated with registry.

    RETURNS:
    Checks if repository 'lambda_functions' exists. 
    If it exists, returns status code 200. 
    If repository does not exist, creates repository 'lambda_functions'.
    Returns status code 200.
    """

    # Establish ECR Client:
    client = boto3.client('ecr')

    # Check if repository exists:
    try:
        response = response = client.describe_repositories(
            registryId=repo_name,
            repositoryNames=[
                'lambda_functions',
            ])
        return f"Lambda_functions already exists."
    except Exception as e:
        try:
            response = client.create_repository(
                registryId=repo_name,
                repositoryName='lambda_functions')
            return f"Status: {response['ResponseMetadata']['HTTPStatusCode']}. Repository 'lambda_functions' created."
        except Exception as e:
            return e


check_ecr(repo)
