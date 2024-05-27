import os
import boto3

# Access the AWS_ECR environment variable:
repo = os.getenv("AWS_ECR")


def check_ecr(repo_name=repo):
    """
    ARGS:
    Repo ID.  The AWS account ID associated with registry.

    RETURNS:
    Status 200 code if repository created. 
    Status 200 code if repository already exists.
    """

    # Establish ECR Client:
    client = boto3.client('ecr')
    # Attempt to create repository:
    try:
        response = client.create_repository(
            registryId=repo_name,
            repositoryName='lambda_functions')
        return f"Status: {response['ResponseMetadata']['HTTPStatusCode']}. Repository 'lambda_functions' created."

    except Exception as e:
        response = response = client.describe_repositories(
            registryId=repo_name,
            repositoryNames=[
                'lambda_functions',
            ])


check_ecr(repo)
