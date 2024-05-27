import os
import boto3
from botocore.exceptions import ClientError
import json

# Access the AWS_ECR environment variable:
repo = os.getenv("AWS_ECR")
account_id = os.getenv("AWS_USER_ACCOUNT_ID")


def create_ecr(repo_name=repo):
    """
    ARGS:
    String: Amazon account ID number.

    RETURNS:
    This function attempts to create an ECR repository 'lambda_functions'.

    If repository successfully created returns string:
    "Status: 200. Repository lambda_functions created."

    If repository already exists returns string:
    "Status: 200. Repository lambda_functions already exists."

    If error - returns error.
    """

    # Establish ECR Client:
    client = boto3.client('ecr')
    # Attempt to create repository:
    try:
        response = client.create_repository(
            registryId=repo_name,
            repositoryName='lambda_functions')
        return f"Status: {response['ResponseMetadata']['HTTPStatusCode']}. Repository {response['repository']['repositoryName']} created."

    except ClientError as e:
        # If unable to create repository check repository already exists:
        if e.response['Error']['Code'] == 'RepositoryAlreadyExistsException':
            response = response = client.describe_repositories(
                registryId=repo_name,
                repositoryNames=[
                    'lambda_functions',
                ])

            return f"Status: {response['ResponseMetadata']['HTTPStatusCode']}.  Repository: {response['repositories'][0]['repositoryName']} already exists."
        else:
            # If unable to check repository exists raise error:
            raise


def id_to_parameter_store(string):
    """
    The purpose of this function is to accept a number as a string
    and write it to the AWS Parameter Store.  The number should be
    the AWS account ID.

    ARGS:
    AWS Account ID as a string. 

    Returns:
    String: 
    """
    client = boto3.client('secretsmanager')
    dict = {'my_secret_string': string}
    json_dict = json.dumps(dict)
    try:
        response = client.create_secret(
            Name='account_id_two',
            SecretString=json_dict,
            ForceOverwriteReplicaSecret=True | False
        )
        return f"Status: {response['ResponseMetadata']['HTTPStatusCode']}.  Account id stored successfully."
    except ClientError as e:
        if e.response['Error']['Code'] == 'ResourceExistsException':
            return 'ID already stored.'
        else:
            raise


create_ecr(repo)
id_to_parameter_store(account_id)

# create_ecr('lambda_functions')
# id_to_parameter_store('211125534329')
