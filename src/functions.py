import boto3
import json
from pprint import pprint
from datetime import datetime


def get_bucket_names():
    """
    Args:
    ------
    None.

    Returns:
    ------
    Object containing names of S3 buckets. Example:

    {'ingestion': 'ingestion-20240304201826545600000001', 
    'process': 'process-20240304201826547200000003',
    'storage': 'storage-20240304201826546800000002'}

    """
    client = boto3.client('ssm')
    bucket_obj = {'ingestion': None, 'process': None,
                  'storage': None}
    for name in bucket_obj:
        bucket_obj[name] = client.get_parameter(
            Name=f"/{name}")['Parameter']['Value']
    return bucket_obj


def aws_time():
    """
    ## Args:
    None.
    ---
    ## Returns:
    ---
    - datetime object stored in aws parameters store.

    Returns a message: "File path created: {date_str}.  File added!"
    This function accesses the time stored in AWS Parameter Store.
    This function will return a datetime OBJECT.
    """
    client = boto3.client('ssm')
    str = client.get_parameter(Name='/time')['Parameter']['Value']
    return datetime.strptime(str, '%Y-%m-%d %H:%M:%S.%f')


print(aws_time())
