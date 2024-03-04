import boto3
import json


def read_bucket_names():
    """
    Args:
    ------
    None.

    Returns:
    ------
    Object containing names of S3 buckets.
    """
    s3 = boto3.client('s3')
    bucket_name = "terraform-xrs"
    object_key = "tf-state"
    response = s3.get_object(Bucket=bucket_name, Key=object_key)
    data = json.loads(response['Body'].read().decode('utf-8'))['resources']
    bucket_obj = {'ingestion': None, 'process': None, 'storage': None}

    for key in data:
        print(key['instances'][0]['attributes']['bucket'])

    # Creates a list of bucket names.

    # bucket_list = [key['instances'][0]['attributes']['bucket'] for key in data]
    # for bucket in bucket_list:
    #     if bucket[0:9] == 'ingestion':
    #         bucket_obj['ingestion'] = bucket
    #     elif bucket[0:7] == 'process':
    #         bucket_obj['process'] = bucket
    #     elif bucket[0:7] == 'storage':
    #         bucket_obj['storage'] = bucket
    pass


read_bucket_names()
