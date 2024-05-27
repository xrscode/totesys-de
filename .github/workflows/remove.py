import os
import boto3

# Access the AWS_ECR environment variable:
repo = os.getenv("AWS_ECR")


def remove_ecr(repo_id):
    """
    ARGS:
    Repo ID.  The AWS account ID associated with registry.

    RETURNS:
    If successfully deleted returns string:
    Status: 200.  Lambda_functions successfully deleted.

    Else returns error.
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
        return f"Status: {response['ResponseMetadata']['HTTPStatusCode']}.  Lambda_functions successfully deleted."
    except Exception as e:
        return e


remove_ecr(repo)
# remove_ecr('211125534329')
